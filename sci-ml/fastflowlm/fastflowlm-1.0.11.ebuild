# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit cmake flag-o-matic optfeature python-single-r1 systemd toolchain-funcs

DESCRIPTION="NPU-first LLM runtime for AMD Ryzen AI (XDNA2) processors"
HOMEPAGE="
	https://fastflowlm.com/
	https://github.com/ROCm/FastFlowLM
"

# Pinned tokenizers-cpp tree and its nested submodules; recheck on bumps.
TOKENIZERS_CPP_COMMIT="acbdc5a27ae01ba74cda756f94da698d40f11dfe"
SENTENCEPIECE_COMMIT="11051e3b73b3a6222a52acd720e39805dc7545ab"
MSGPACK_COMMIT="092bc69b6e815980bce7808595c914dd3a29f905"
# 1.0.10 adds xgrammar for constrained decoding; it needs dlpack's headers
# from its own submodule. verified 2026-10-25
XGRAMMAR_COMMIT="97787376faee5ed8466cfad57c99855e4ce2f6aa"
DLPACK_COMMIT="bbd2f4d32427e548797929af08cfe2a9cbb3cf12"

SRC_URI="
	https://github.com/ROCm/FastFlowLM/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/mlc-ai/tokenizers-cpp/archive/${TOKENIZERS_CPP_COMMIT}.tar.gz
		-> tokenizers-cpp-${TOKENIZERS_CPP_COMMIT}.tar.gz
	https://github.com/google/sentencepiece/archive/${SENTENCEPIECE_COMMIT}.tar.gz
		-> sentencepiece-${SENTENCEPIECE_COMMIT}.tar.gz
	https://github.com/msgpack/msgpack-c/archive/${MSGPACK_COMMIT}.tar.gz
		-> msgpack-c-${MSGPACK_COMMIT}.tar.gz
	https://github.com/mlc-ai/xgrammar/archive/${XGRAMMAR_COMMIT}.tar.gz
		-> xgrammar-${XGRAMMAR_COMMIT}.tar.gz
	https://github.com/dmlc/dlpack/archive/${DLPACK_COMMIT}.tar.gz
		-> xgrammar-dlpack-${DLPACK_COMMIT}.tar.gz
"
S="${WORKDIR}/FastFlowLM-${PV}"

# The CLI is MIT. Since 1.0.9 the bundled NPU kernels and engine libraries
# are under upstream's LICENSE_BINARY.txt, which replaced TERMS.md: closed
# source, free for any use, redistributable unmodified with the licence.
# verified 2026-10-16
LICENSE="MIT FastFlowLM-NPU-Binary"
# Vendored code compiled into flm: xgrammar and dlpack (Apache-2.0), picojson
# (BSD-2), pocketfft (BSD), lodepng (ZLIB), dr_libs (public domain or MIT-0).
# verified 2026-10-25
LICENSE+=" Apache-2.0 BSD BSD-2 ZLIB || ( public-domain MIT-0 )"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gemma4e-source hrx openrc systemd"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# Cargo (inside tokenizers-cpp/rust) fetches the crates the shipped Cargo.lock
# pins at build time; vendoring them via cargo.eclass would allow an offline
# build.
RESTRICT="network-sandbox"

BDEPEND="
	>=dev-build/cmake-3.22
	dev-build/ninja
	|| ( dev-lang/rust dev-lang/rust-bin )
	virtual/pkgconfig
	hrx? ( dev-util/patchelf )
"
# Python is for flm-custom-sync only.
# USE=hrx swaps XRT for the HRX runtime, at the exact release this version
# names in hrx-integration/hrx-release.env. verified 2026-10-29
RDEPEND="
	${PYTHON_DEPS}
	dev-libs/xdna-driver
	hrx? ( ~dev-libs/hrx-amdxdna-bin-0.1.0_p20261023 )
	!hrx? (
		dev-util/xrt
		dev-libs/xrt-xdna
	)
	dev-libs/boost:=
	dev-libs/libedit
	media-libs/libjpeg-turbo:=
	media-libs/libogg
	media-libs/libvorbis
	media-libs/libwebp:=
	media-libs/opus
	net-misc/curl:=
"
# xrt-2.21.75-r1 is the first to install aiebu's headers.
DEPEND="
	${RDEPEND}
	!hrx? ( >=dev-util/xrt-2.21.75-r1 )
"

CMAKE_USE_DIR="${S}/src"

# Upstream fetches and statically builds libjpeg-turbo, libwebp (since
# 1.0.11), opus, ogg and vorbis at build time; use the system libraries
# instead. verified 2026-10-29
PATCHES=(
	"${FILESDIR}/${PN}-1.0.11-system-codecs.patch"
)

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

src_unpack() {
	default

	rmdir "${S}/third_party/tokenizers-cpp" || die
	mv "${WORKDIR}/tokenizers-cpp-${TOKENIZERS_CPP_COMMIT}" \
		"${S}/third_party/tokenizers-cpp" || die

	rmdir "${S}/third_party/tokenizers-cpp/sentencepiece" || die
	mv "${WORKDIR}/sentencepiece-${SENTENCEPIECE_COMMIT}" \
		"${S}/third_party/tokenizers-cpp/sentencepiece" || die

	rmdir "${S}/third_party/tokenizers-cpp/msgpack" || die
	mv "${WORKDIR}/msgpack-c-${MSGPACK_COMMIT}" \
		"${S}/third_party/tokenizers-cpp/msgpack" || die

	rmdir "${S}/third_party/xgrammar" || die
	mv "${WORKDIR}/xgrammar-${XGRAMMAR_COMMIT}" \
		"${S}/third_party/xgrammar" || die

	rmdir "${S}/third_party/xgrammar/3rdparty/dlpack" || die
	mv "${WORKDIR}/dlpack-${DLPACK_COMMIT}" \
		"${S}/third_party/xgrammar/3rdparty/dlpack" || die
}

src_prepare() {
	# tokenizers-cpp ships no Cargo.lock, so cargo would resolve its semver ranges
	# afresh on every build. Pin the crates and make cargo enforce the pin.
	# Lockfile generated 2026-10-08 for this tokenizers-cpp commit.
	local tok="${S}/third_party/tokenizers-cpp"
	cp "${FILESDIR}/tokenizers-cpp-${TOKENIZERS_CPP_COMMIT:0:7}-Cargo.lock" \
		"${tok}/rust/Cargo.lock" || die
	sed -i '/^set(TOKENIZERS_CPP_CARGO_FLAGS "")$/a list(APPEND TOKENIZERS_CPP_CARGO_FLAGS --locked)' \
		"${tok}/CMakeLists.txt" || die
	grep -q -- "TOKENIZERS_CPP_CARGO_FLAGS --locked" "${tok}/CMakeLists.txt" || die

	# Link XRT's aiebu, not the prebuilt copy upstream ships. flm calls only
	# aiebu_assembler_get_elf(), declared identically by the aiebu of every
	# packaged XRT. verified 2026-10-05
	rm "${S}"/src/lib/xrt/{libaiebu.a,aiebu_static.lib} || die
	rm -r "${S}"/src/include/aiebu || die

	# npu_cmd.hpp uses UCHAR_MAX without <climits>. flm gets it through
	# other headers; the source-built Gemma 4 engine includes this header
	# first and fails with GCC 16. The file has CRLF line endings, hence
	# sed rather than a patch. Still needed at 1.0.11. verified 2026-10-29
	local npu_cmd="${S}/src/include/npu_utils/instr_utils/npu_cmd.hpp"
	sed -i 's/^#include <cstdint>/#include <climits>\n&/' "${npu_cmd}" || die
	grep -q '^#include <climits>' "${npu_cmd}" || die "climits include not added"

	cmake_src_prepare
}

src_configure() {
	# Set preset-only values explicitly. CMAKE_XCLBIN_PREFIX must match the install
	# path or runtime searches beside the executable (#269); NPU_VERSION only
	# satisfies a Linux guard. USE=hrx picks the NPU runtime.
	# 1.0.8 adds a ryzenai-corelib backend (FLM_ENABLE_CORE, named
	# FLM_ENABLE_RAI before 1.0.10), kept off: the library is not
	# public, and a build that links it targets an unreleased NPU generation
	# and offers none of the current models. It also adds the source of the
	# Gemma 4 E2B/E4B engine, built in place of the prebuilt
	# libgemma4e_npu.so under USE=gemma4e-source. Upstream compiles it with
	# fixed AVX-512 flags; FLM_ENGINE_NATIVE_ARCH stays off so CXXFLAGS decide
	# the rest. Verified 2026-10-13.
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="/opt/fastflowlm"
		-DCMAKE_XCLBIN_PREFIX="/opt/fastflowlm/share/flm"
		-DFLM_VERSION="${PV}"
		-DNPU_VERSION="32.0.203.304"
		-DFLM_USE_HRX=$(usex hrx)
		-DFLM_ENABLE_CORE=OFF
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

	# Expose the NPU runtime and bundled libraries at runtime
	# (lemonade-sdk/lemonade#1315).
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
	# FFmpeg 6, 7 or 8 is opened with dlopen() when a request carries a
	# video. verified 2026-10-29
	optfeature "video input to the d3 decision models" media-video/ffmpeg

	elog ""
	elog "FastFlowLM ${PV} installed to /opt/fastflowlm."
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
	ewarn ""
	ewarn "1.0.3 requantised the Qwen3.5 family and Qwen3.6-MoE from Q4_1 to"
	ewarn "Q4_K. Weights pulled by an earlier FastFlowLM are NOT compatible."
	ewarn "Re-pull any of these you have cached:"
	ewarn "    flm pull qwen3.5:0.8b   qwen3.5:2b   qwen3.5:4b"
	ewarn "    flm pull qwen3.5:9b     qwen3.6-moe:35b-a3b"
	ewarn ""
	elog "Run 'env-update && source /etc/profile' to pick up paths."
}
