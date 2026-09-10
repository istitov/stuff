# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake systemd

DESCRIPTION="NPU-first LLM runtime for AMD Ryzen AI (XDNA2) processors"
HOMEPAGE="
	https://fastflowlm.com/
	https://github.com/ROCm/FastFlowLM
"

# Fixed submodule revisions used by the 1.0.5 tag. tokenizers-cpp's nested
# sentencepiece and msgpack revisions match these archives.
TOKENIZERS_CPP_COMMIT="acbdc5a27ae01ba74cda756f94da698d40f11dfe"
SENTENCEPIECE_COMMIT="11051e3b73b3a6222a52acd720e39805dc7545ab"
MSGPACK_COMMIT="092bc69b6e815980bce7808595c914dd3a29f905"

SRC_URI="
	https://github.com/ROCm/FastFlowLM/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/mlc-ai/tokenizers-cpp/archive/${TOKENIZERS_CPP_COMMIT}.tar.gz
		-> tokenizers-cpp-${TOKENIZERS_CPP_COMMIT}.tar.gz
	https://github.com/google/sentencepiece/archive/${SENTENCEPIECE_COMMIT}.tar.gz
		-> sentencepiece-${SENTENCEPIECE_COMMIT}.tar.gz
	https://github.com/msgpack/msgpack-c/archive/${MSGPACK_COMMIT}.tar.gz
		-> msgpack-c-${MSGPACK_COMMIT}.tar.gz
"
S="${WORKDIR}/FastFlowLM-${PV}"

# The CLI is MIT-licensed; bundled NPU kernels use FastFlowLM-Binary
# (assets/superseded/LICENSE_BINARY.txt).
LICENSE="MIT FastFlowLM-Binary"
SLOT="0"
KEYWORDS="~amd64"
IUSE="openrc systemd"

# Cargo (inside tokenizers-cpp/rust) fetches crates at build time.
# Proper GURU submission would require pre-vendored crates via cargo.eclass.
RESTRICT="mirror network-sandbox"

BDEPEND="
	>=dev-build/cmake-3.22
	dev-build/ninja
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
DEPEND="${RDEPEND}"

CMAKE_USE_DIR="${S}/src"

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
}

src_prepare() {
	# Drop upstream's symlink-into-/usr/local/bin block; we provide our
	# own wrapper via newbin + env.d below.
	sed -i '/if.*NOT WIN32.*CMAKE_INSTALL_PREFIX/,/endif()/d' \
		"${S}/src/CMakeLists.txt" || die
	# Exclude a backup binary caught by upstream's *.so* install glob.
	rm "${S}/src/lib/xrt/libq4_npu_eXpress.so.bak-20260826" || die
	cmake_src_prepare
}

src_configure() {
	# The upstream preset supplies these values; set them explicitly because
	# cmake.eclass does not use it. NPU_VERSION is upstream's unchanged
	# Windows-driver marker. CMAKE_XCLBIN_PREFIX fixes runtime data lookup
	# (ROCm/FastFlowLM#269). Keep the unpackaged HRX backend disabled.
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="/opt/fastflowlm"
		-DCMAKE_XCLBIN_PREFIX="/opt/fastflowlm/share/flm"
		-DFLM_VERSION="${PV}"
		-DNPU_VERSION="32.0.203.304"
		-DFLM_USE_HRX=OFF
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	local flm_libdir="/opt/fastflowlm/$(get_libdir)"

	# Wrapper so flm finds XRT and its own libs at runtime
	# (lemonade-sdk/lemonade#1315).
	newbin - flm <<-EOF
	#!/usr/bin/env bash
	set -euo pipefail
	export LD_LIBRARY_PATH="${flm_libdir}:/opt/xilinx/xrt/lib\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}"
	export FLM_CONFIG_PATH="\${FLM_CONFIG_PATH:-/opt/fastflowlm/share/flm/model_list.json}"
	exec /opt/fastflowlm/bin/flm "\$@"
	EOF

	# Helper that patches HuggingFace Whisper config.json so FLM's
	# decoder-only LM_Config validator doesn't crash on it. Idempotent;
	# user runs once after `flm pull whisper-v3:turbo`.
	# Upstream bug: https://github.com/ROCm/FastFlowLM/issues/545
	newbin "${FILESDIR}/flm-patch-whisper" flm-patch-whisper

	newenvd - 99fastflowlm <<-EOF
	LDPATH="${flm_libdir}"
	PATH="/opt/fastflowlm/bin"
	FLM_CONFIG_PATH="/opt/fastflowlm/share/flm/model_list.json"
	EOF

	if use openrc; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	fi
	if use systemd; then
		systemd_newunit "${FILESDIR}/${PN}.service" "${PN}@.service"
	fi
}

pkg_postinst() {
	elog ""
	elog "FastFlowLM ${PV} installed to /opt/fastflowlm."
	elog ""
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
	ewarn "Whisper ASR models (whisper-v3:turbo, ...) crash flm at startup"
	ewarn "until their config.json is patched: FLM's LM_Config validator"
	ewarn "asserts on decoder-only LM-shape fields that HuggingFace Whisper"
	ewarn "configs don't carry."
	ewarn "Upstream bug: https://github.com/ROCm/FastFlowLM/issues/545"
	ewarn ""
	ewarn "After 'flm pull whisper-v3:turbo' (or any Whisper model), run"
	ewarn "    flm-patch-whisper"
	ewarn "to patch the downloaded config.json idempotently."
	ewarn ""
	ewarn "1.0.3 requantised the Qwen3.5 family and Qwen3.6-MoE from Q4_1 to"
	ewarn "Q4_K. Weights pulled by an earlier FastFlowLM are NOT compatible."
	ewarn "Re-pull any of these you have cached:"
	ewarn "    flm pull qwen3.5:0.8b   qwen3.5:2b   qwen3.5:4b"
	ewarn "    flm pull qwen3.5:9b     qwen3.6-moe:35b-a3b"
	ewarn ""
	elog "Run 'env-update && source /etc/profile' to pick up paths."
}
