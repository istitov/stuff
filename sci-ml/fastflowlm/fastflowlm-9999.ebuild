
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

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
"
DEPEND="${RDEPEND}"

CMAKE_USE_DIR="${S}/src"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="/opt/fastflowlm"
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

	newenvd - 99fastflowlm <<-'EOF'
	LDPATH="/opt/fastflowlm/lib"
	PATH="/opt/fastflowlm/bin"
	FLM_CONFIG_PATH="/opt/fastflowlm/share/flm/model_list.json"
	EOF
}

pkg_postinst() {
	elog ""
	elog "FastFlowLM ${PV} (live) installed to /opt/fastflowlm."
	elog ""
	elog "Quick start:"
	elog "  flm validate          # verify NPU stack"
	elog "  flm pull llama3.2:3b  # download a model"
	elog "  flm run llama3.2:3b   # chat with it"
	elog ""
	elog "Models stored in ~/.config/flm/ (override: FLM_MODEL_PATH)."
	elog ""
	elog "Ensure memlock is unlimited.  If 'ulimit -l' is not 'unlimited',"
	elog "add to /etc/security/limits.d/99-amdxdna.conf:"
	elog "  *  soft  memlock  unlimited"
	elog "  *  hard  memlock  unlimited"
	elog ""
	elog "Run 'env-update && source /etc/profile' to pick up library paths."
	elog ""
	elog "This is a live ebuild tracking upstream main. Rebuild with:"
	elog "  emerge --oneshot =dev-ml/fastflowlm-9999"
}
