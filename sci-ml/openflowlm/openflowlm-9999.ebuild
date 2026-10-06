# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# The kernel venv must match this interpreter, and the mlir-aie 1.4.2 wheels
# stop at cp314. verified 2026-10-06
PYTHON_COMPAT=( python3_{12..14} )

inherit cmake git-r3 multiprocessing python-any-r1

DESCRIPTION="Community fork of FastFlowLM with open NPU kernels for AMD Ryzen AI (XDNA2)"
HOMEPAGE="https://github.com/Atomic-Germ/OpenFlowLM-Next"
EGIT_REPO_URI="https://github.com/Atomic-Germ/OpenFlowLM-Next.git"
EGIT_SUBMODULES=( '*' )

# The engine, CLI and open kernels are MIT; the statically linked
# tokenizers-cpp, sentencepiece and Hugging Face tokenizers are Apache-2.0.
# The closed engine libraries and kernels kept from FastFlowLM (vision,
# audio, Gemma 4, GPT-OSS, Whisper) are under FastFlowLM's terms, which grant
# no redistribution.
LICENSE="MIT Apache-2.0 FastFlowLM-Terms"
SLOT="0"

# The kernel toolchain (mlir-aie and Peano wheels) is pip-installed into a
# build-time venv, and tokenizers-cpp fetches Rust crates.
PROPERTIES="live"
RESTRICT="bindist network-sandbox"

# export-kernels.py builds the venv with uv when it is on PATH, and with
# python -m venv + pip otherwise; only the uv path is build-verified.
BDEPEND="
	${PYTHON_DEPS}
	>=dev-build/cmake-3.25
	dev-build/ninja
	dev-python/uv
	dev-vcs/git
	|| ( dev-lang/rust dev-lang/rust-bin )
"
RDEPEND="
	dev-util/xrt
	dev-libs/xdna-driver
	dev-libs/xrt-xdna
	media-video/ffmpeg:=
	net-misc/curl:=
	dev-libs/boost:=
	sci-libs/fftw:3.0=
	sys-libs/ncurses:=
	sys-libs/readline:=
"
# xclbinutil and aiebu-asm come from XRT and are needed for the kernel export.
DEPEND="
	${RDEPEND}
	>=dev-util/xrt-2.21.75-r1
"

CMAKE_USE_DIR="${S}/src"

# Every engine library is a FastFlowLM prebuilt; only bin/oflm is compiled.
QA_PREBUILT="opt/openflowlm/lib*/lib*.so"

src_prepare() {
	# Link XRT's aiebu, not the prebuilt copy upstream ships.
	rm "${S}"/src/lib/xrt/{libaiebu.a,aiebu_static.lib} || die
	rm -r "${S}"/src/include/aiebu || die
	cmake_src_prepare
}

src_configure() {
	# OFLM_VERSION and NPU_VERSION are preset-only values the build refuses to
	# run without; read the version from the root presets so it tracks main.
	local oflm_version
	oflm_version=$("${EPYTHON}" -c '
import json, sys
p = json.load(open(sys.argv[1]))
print(next(c["cacheVariables"]["OFLM_VERSION"] for c in p["configurePresets"]
	if "OFLM_VERSION" in c.get("cacheVariables", {})))
' "${S}/CMakePresets.json") || die

	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="/opt/openflowlm"
		-DCMAKE_XCLBIN_PREFIX="/opt/openflowlm/share/oflm"
		-DOFLM_VERSION="${oflm_version}"
		-DNPU_VERSION="32.0.203.304"
		-DOFLM_USE_HRX=OFF
		# Driven from src_compile instead, so the BERT sets can be skipped.
		-DOFLM_BUILD_KERNELS=OFF
		# oflm-test and q4nx-build need undeclared Python stacks (torch,
		# transformers, modelscope, a pinned openai).
		-DOFLM_BUILD_UTILITIES=OFF
		# The wrapper and env.d below replace /usr/bin/oflm + profile.d.
		-DOFLM_INSTALL_PATH_PLUMBING=OFF
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile

	# The open LLM kernels compile without a device. The BERT embedding sets
	# allocate buffers on the NPU itself during export, and a package build
	# should not depend on the device, so they are skipped.
	#
	# granite42-3b and phi4-mini-4b fail upstream: their attention pv kernels
	# have an odd number of 256-row blocks (M=1280, M=768), which
	# gemm_pretiled.py cannot split into its row-block pairs ("tensor does not
	# divide evenly into tile groups"). verified 2026-10-06
	local -x OFLM_VENV_DIR="${T}/ironvenv"
	local -x PIP_CACHE_DIR="${T}/pip-cache"
	"${EPYTHON}" utilities/export-kernels.py --skip-bert \
		--skip-specs granite42-3b,phi4-mini-4b \
		--jobs "$(makeopts_jobs)" || die "kernel export failed"
}

src_install() {
	cmake_src_install

	local oflm_libdir="/opt/openflowlm/$(get_libdir)"

	newbin - oflm <<-EOF
	#!/usr/bin/env bash
	set -euo pipefail
	export LD_LIBRARY_PATH="${oflm_libdir}\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}"
	export OFLM_CONFIG_PATH="\${OFLM_CONFIG_PATH:-/opt/openflowlm/share/oflm/model_list.json}"
	exec /opt/openflowlm/bin/oflm "\$@"
	EOF

	newenvd - 99openflowlm <<-EOF
	LDPATH="${oflm_libdir}"
	OFLM_CONFIG_PATH="/opt/openflowlm/share/oflm/model_list.json"
	EOF
}

pkg_postinst() {
	elog "OpenFlowLM (live) installed to /opt/openflowlm; run it as 'oflm'."
	elog ""
	elog "  oflm validate         # verify the NPU stack"
	elog "  oflm run llama3.2:1b  # download and chat"
	elog ""
	elog "The open BERT embedding kernels are not built: they need the NPU at"
	elog "build time, so bge-*, all-minilm, nomic-embed-text and"
	elog "gte-multilingual will not load."
	elog ""
	elog "The NPU needs an unlimited memlock limit. If 'ulimit -l' is not"
	elog "'unlimited', add to /etc/security/limits.d/99-amdxdna.conf:"
	elog "  *  soft  memlock  unlimited"
	elog "  *  hard  memlock  unlimited"
}
