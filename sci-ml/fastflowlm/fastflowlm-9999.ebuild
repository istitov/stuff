# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit cmake flag-o-matic git-r3 python-single-r1 systemd toolchain-funcs

DESCRIPTION="NPU-first LLM runtime for AMD Ryzen AI (XDNA2) processors"
HOMEPAGE="
	https://fastflowlm.com/
	https://github.com/ROCm/FastFlowLM
"

EGIT_REPO_URI="https://github.com/ROCm/FastFlowLM.git"
EGIT_SUBMODULES=( '*' )

# The CLI is MIT. Since 1.0.9 the bundled NPU kernels and engine libraries
# are under upstream's LICENSE_BINARY.txt, which replaced TERMS.md: closed
# source, free for any use, redistributable unmodified with the licence.
# verified 2026-10-16
LICENSE="MIT FastFlowLM-NPU-Binary"
SLOT="0"
IUSE="gemma4e-source hrx openrc systemd"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# tokenizers-cpp fetches Rust crates during the live build.
PROPERTIES="live"
RESTRICT="network-sandbox"

BDEPEND="
	>=dev-build/cmake-3.22
	dev-build/ninja
	|| ( dev-lang/rust dev-lang/rust-bin )
	hrx? ( dev-util/patchelf )
"
# Python is for flm-custom-sync only.
# USE=hrx swaps XRT for the HRX runtime. main names one exact HRX release
# in hrx-integration/hrx-release.env; re-read it when a sync fails here.
# verified 2026-10-13 against main
RDEPEND="
	${PYTHON_DEPS}
	dev-libs/xdna-driver
	hrx? ( ~dev-libs/hrx-amdxdna-bin-0.1.0_p20260915 )
	!hrx? (
		dev-util/xrt
		dev-libs/xrt-xdna
	)
	media-video/ffmpeg:=
	net-misc/curl:=
	dev-libs/boost:=
	sci-libs/fftw:3.0=
	sys-libs/readline:=
"
# xrt-2.21.75-r1 is the first to install aiebu's headers.
DEPEND="
	${RDEPEND}
	!hrx? ( >=dev-util/xrt-2.21.75-r1 )
"

CMAKE_USE_DIR="${S}/src"

# The source-built engine needs OpenMP (find_package REQUIRED).
pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]] && use gemma4e-source; then
		tc-check-openmp
	fi
}

pkg_setup() {
	if [[ ${MERGE_TYPE} != binary ]] && use gemma4e-source; then
		tc-check-openmp
	fi
	python-single-r1_pkg_setup
}

src_prepare() {
	# Link XRT's aiebu, not the prebuilt copy upstream ships. flm calls only
	# aiebu_assembler_get_elf(), declared identically by the aiebu of every
	# packaged XRT. verified 2026-10-05
	rm "${S}"/src/lib/xrt/{libaiebu.a,aiebu_static.lib} || die
	rm -r "${S}"/src/include/aiebu || die

	# npu_cmd.hpp uses UCHAR_MAX without <climits>. flm gets it through
	# other headers; the source-built Gemma 4 engine includes this header
	# first and fails with GCC 16. The file has CRLF line endings, hence
	# sed rather than a patch; skipped once upstream adds the include.
	# verified 2026-10-13 against main
	local npu_cmd="${S}/src/include/npu_utils/instr_utils/npu_cmd.hpp"
	if ! grep -q '^#include <climits>' "${npu_cmd}"; then
		sed -i 's/^#include <cstdint>/#include <climits>\n&/' "${npu_cmd}" || die
		grep -q '^#include <climits>' "${npu_cmd}" || die "climits include not added"
	fi

	cmake_src_prepare
}

src_configure() {
	# Set preset-only values explicitly. CMAKE_XCLBIN_PREFIX must match the
	# install path or runtime searches beside the executable (#269);
	# NPU_VERSION only satisfies a Linux guard. USE=hrx picks the NPU runtime.
	# The ryzenai-corelib backend stays off: the library is not public, and
	# a build that links it targets an unreleased NPU generation and offers
	# none of the current models. USE=gemma4e-source builds the Gemma 4
	# E2B/E4B engine in place of the prebuilt libgemma4e_npu.so; upstream
	# compiles it with fixed AVX-512 flags, and FLM_ENGINE_NATIVE_ARCH stays
	# off so CXXFLAGS decide the rest. verified 2026-10-13 against main
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="/opt/fastflowlm"
		-DCMAKE_XCLBIN_PREFIX="/opt/fastflowlm/share/flm"
		-DFLM_VERSION="${PV}"
		-DNPU_VERSION="32.0.203.304"
		-DFLM_USE_HRX=$(usex hrx)
		-DFLM_ENABLE_RAI=OFF
		-DFLM_BUILD_GEMMA4E=$(usex gemma4e-source)
		-DFLM_ENGINE_NATIVE_ARCH=OFF
	)
	# The engine source type-puns through pointers (GCC's strict-aliasing
	# warnings, which Portage reports as a QA notice). verified 2026-10-13
	use gemma4e-source && append-flags -fno-strict-aliasing

	use hrx && mycmakeargs+=(
		-Dhrx_DIR="${ESYSROOT}/opt/hrx-amdxdna/lib/cmake/hrx"
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	local flm_libdir="/opt/fastflowlm/$(get_libdir)"
	local flm_ldpath="${flm_libdir}:/opt/xilinx/xrt/lib" flm_envd_ldpath="${flm_libdir}"

	if use hrx; then
		# Upstream's HRX install puts the engines in <libdir>/flm and copies
		# flm's whole shared-library closure, system libraries included,
		# into <libdir>. Drop the copies and link the packaged libhrx where
		# the RUNPATHs of flm and the engines look for it.
		# verified 2026-10-13
		[[ -d ${ED}${flm_libdir}/flm ]] || die "HRX engine directory missing"
		find "${ED}${flm_libdir}" -mindepth 1 -maxdepth 1 ! -type d -delete || die
		dosym -r /opt/hrx-amdxdna/lib/libhrx.so.0 "${flm_libdir}/libhrx.so.0"
		flm_ldpath="${flm_libdir}/flm:${flm_libdir}"
		flm_envd_ldpath="${flm_libdir}/flm"
	fi

	newbin - flm <<-EOF
	#!/usr/bin/env bash
	set -euo pipefail
	export LD_LIBRARY_PATH="${flm_ldpath}\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}"
	export FLM_CONFIG_PATH="\${FLM_CONFIG_PATH:-/opt/fastflowlm/share/flm/model_list.json}"
	exec /opt/fastflowlm/bin/flm "\$@"
	EOF

	newenvd - 99fastflowlm <<-EOF
	LDPATH="${flm_envd_ldpath}"
	PATH="/opt/fastflowlm/bin"
	FLM_CONFIG_PATH="/opt/fastflowlm/share/flm/model_list.json"
	EOF

	# Registry helper for converted fine-tunes; see its docstring.
	python_doscript "${FILESDIR}/flm-custom-sync"

	if use openrc; then
		# These hand FLM_CONFIG_PATH and FLM_XCLBIN_PATH to the daemon for
		# flm-custom-sync. Versions without the helper use the plain names.
		newinitd "${FILESDIR}/${PN}-1.0.7.initd" "${PN}"
		newconfd "${FILESDIR}/${PN}-1.0.7.confd" "${PN}"
	fi
	if use systemd; then
		systemd_newunit "${FILESDIR}/${PN}.service" "${PN}@.service"
	fi
}

pkg_postinst() {
	elog ""
	elog "FastFlowLM ${PV} (live) installed to /opt/fastflowlm."
	elog ""
	if use hrx; then
		elog "Built on the HRX NPU runtime instead of XRT. Upstream calls its"
		elog "HRX builds a preview; rebuild with USE=-hrx to return to XRT."
		elog ""
	fi
	elog "Quick start (manual):"
	elog "  flm validate          # verify NPU stack"
	elog "  flm pull llama3.2:3b  # download a model"
	elog "  flm run llama3.2:3b   # chat with it"
	elog ""
	if use openrc; then
		elog "OpenRC service (supervise-daemon; rlimit_memlock=unlimited set):"
		elog "  edit /etc/conf.d/fastflowlm and set FLM_USER (required)"
		elog "  other tunables (model, sidecars, port) have safe defaults"
		elog "  rc-service fastflowlm start"
		elog "  rc-update add fastflowlm default     # auto-start at boot"
		elog ""
	fi
	if use systemd; then
		elog "systemd template service (one instance per user, mlock unlimited):"
		elog "  optionally create /etc/default/fastflowlm@<user> to override"
		elog "    FLM_MODEL / FLM_HOST / FLM_PORT / FLM_PMODE / FLM_ASR /"
		elog "    FLM_EMBED / FLM_EXTRA_OPTS"
		elog "  systemctl enable --now fastflowlm@<user>.service"
		elog ""
	fi
	elog "Models stored in ~/.config/flm/ (override: FLM_MODEL_PATH)."
	elog ""
	elog "Converted fine-tunes are registered per user with flm-custom-sync"
	elog "(see flm-custom-sync --help). FastFlowLM uses that registry when"
	elog "FLM_CONFIG_PATH and FLM_XCLBIN_PATH name it."
	if use openrc; then
		elog "The OpenRC service takes both from /etc/conf.d/fastflowlm."
	fi
	if use systemd; then
		elog "The systemd service takes both from /etc/default/fastflowlm@<user>."
	fi
	elog "Run flm-custom-sync again after every upgrade and restart the"
	elog "service: its model list is a copy of the packaged one."
	elog ""
	elog "Ensure memlock is unlimited for INTERACTIVE 'flm run' use too."
	if use openrc || use systemd; then
		elog "(The installed service unit already sets memlock to unlimited.)"
	fi
	elog "If 'ulimit -l' is not 'unlimited' in your shell, add to"
	elog "/etc/security/limits.d/99-amdxdna.conf:"
	elog "  *  soft  memlock  unlimited"
	elog "  *  hard  memlock  unlimited"
	elog ""
	elog "Run 'env-update && source /etc/profile' to pick up library paths."
	elog ""
	elog "This is a live ebuild tracking upstream main. Rebuild with:"
	elog "  emerge --oneshot =sci-ml/fastflowlm-9999"
}
