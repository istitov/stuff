# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit cmake git-r3 python-single-r1 systemd

DESCRIPTION="NPU-first LLM runtime for AMD Ryzen AI (XDNA2) processors"
HOMEPAGE="
	https://fastflowlm.com/
	https://github.com/ROCm/FastFlowLM
"

EGIT_REPO_URI="https://github.com/ROCm/FastFlowLM.git"
EGIT_SUBMODULES=( '*' )

# The CLI is MIT. The bundled NPU kernels are proprietary under upstream's
# TERMS.md, which replaced the older FastFlowLM-Binary licence (shipped as
# superseded): free use, commercially up to a revenue threshold, and no
# grant to redistribute, hence bindist. verified 2026-10-05
LICENSE="MIT FastFlowLM-Terms"
SLOT="0"
IUSE="openrc systemd"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# tokenizers-cpp fetches Rust crates during the live build.
PROPERTIES="live"
RESTRICT="bindist network-sandbox"

BDEPEND="
	>=dev-build/cmake-3.22
	dev-build/ninja
	|| ( dev-lang/rust dev-lang/rust-bin )
"
# Python is for flm-custom-sync only.
RDEPEND="
	${PYTHON_DEPS}
	dev-util/xrt
	dev-libs/xdna-driver
	dev-libs/xrt-xdna
	media-video/ffmpeg:=
	net-misc/curl:=
	dev-libs/boost:=
	sci-libs/fftw:3.0=
	sys-libs/readline:=
"
# xrt-2.21.75-r1 is the first to install aiebu's headers.
DEPEND="
	${RDEPEND}
	>=dev-util/xrt-2.21.75-r1
"

CMAKE_USE_DIR="${S}/src"

src_prepare() {
	# Link XRT's aiebu, not the prebuilt copy upstream ships. flm calls only
	# aiebu_assembler_get_elf(), declared identically by the aiebu of every
	# packaged XRT. verified 2026-10-05
	rm "${S}"/src/lib/xrt/{libaiebu.a,aiebu_static.lib} || die
	rm -r "${S}"/src/include/aiebu || die
	cmake_src_prepare
}

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

	local flm_libdir="/opt/fastflowlm/$(get_libdir)"

	newbin - flm <<-EOF
	#!/usr/bin/env bash
	set -euo pipefail
	export LD_LIBRARY_PATH="${flm_libdir}:/opt/xilinx/xrt/lib\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}"
	export FLM_CONFIG_PATH="\${FLM_CONFIG_PATH:-/opt/fastflowlm/share/flm/model_list.json}"
	exec /opt/fastflowlm/bin/flm "\$@"
	EOF

	newenvd - 99fastflowlm <<-EOF
	LDPATH="${flm_libdir}"
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
