
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 systemd

DESCRIPTION="NPU-first LLM runtime for AMD Ryzen AI (XDNA2) processors"
HOMEPAGE="
	https://fastflowlm.com/
	https://github.com/FastFlowLM/FastFlowLM
"

EGIT_REPO_URI="https://github.com/FastFlowLM/FastFlowLM.git"
EGIT_SUBMODULES=( '*' )

LICENSE="MIT FastFlowLM-Binary"
SLOT="0"
# No KEYWORDS for live ebuild.
IUSE="openrc systemd"

# Cargo (inside tokenizers-cpp/rust) fetches crates at build time —
# same as the tagged ebuilds, hence both PROPERTIES=live + RESTRICT.
PROPERTIES="live"
RESTRICT="network-sandbox"

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
	sys-libs/readline:=
"
DEPEND="${RDEPEND}"

CMAKE_USE_DIR="${S}/src"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="/opt/fastflowlm"
		-DCMAKE_XCLBIN_PREFIX="/opt/fastflowlm/share/flm"
		-DFLM_VERSION="${PV}"
		-DNPU_VERSION="32.0.203.304"
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	newbin - flm <<-'EOF'
	#!/usr/bin/env bash
	set -euo pipefail
	export LD_LIBRARY_PATH="/opt/fastflowlm/lib:/opt/xilinx/xrt/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
	export FLM_CONFIG_PATH="${FLM_CONFIG_PATH:-/opt/fastflowlm/share/flm/model_list.json}"
	exec /opt/fastflowlm/bin/flm "$@"
	EOF

	# Helper that patches HuggingFace Whisper config.json so FLM's
	# decoder-only LM_Config validator doesn't crash on it. Idempotent;
	# user runs once after `flm pull whisper-v3:turbo`.
	# Upstream bug: https://github.com/FastFlowLM/FastFlowLM/issues/545
	newbin "${FILESDIR}/flm-patch-whisper" flm-patch-whisper

	newenvd - 99fastflowlm <<-'EOF'
	LDPATH="/opt/fastflowlm/lib"
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
	elog "FastFlowLM ${PV} (live) installed to /opt/fastflowlm."
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
	ewarn "Upstream bug: https://github.com/FastFlowLM/FastFlowLM/issues/545"
	ewarn ""
	ewarn "After 'flm pull whisper-v3:turbo' (or any Whisper model), run"
	ewarn "    flm-patch-whisper"
	ewarn "to patch the downloaded config.json idempotently."
	ewarn ""
	elog "Run 'env-update && source /etc/profile' to pick up library paths."
	elog ""
	elog "This is a live ebuild tracking upstream main. Rebuild with:"
	elog "  emerge --oneshot =dev-ml/fastflowlm-9999"
}
