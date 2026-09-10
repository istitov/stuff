# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Open source XRD and Rietveld refinement engine"
# bgmn.de has no TLS endpoint. verified 2026-05-09
HOMEPAGE="https://www.profex-xrd.org http://www.bgmn.de/"
SRC_URI="https://www.profex-xrd.org/wp-content/uploads/2022/10/${P}-x86_64.tar.gz"
S="${WORKDIR}/${PN}-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

# Prebuilt binaries; ldd shows only glibc libraries. Do not strip.
RESTRICT="strip mirror"

QA_PREBUILT="opt/bgmn/*"

src_install() {
	# Binaries require EFLECH to locate their data; install under /opt and wrap.
	insinto /opt/${PN}
	doins *.dat *.lam *.mdr *.ano *.cfg err.msg \
		spacegrp index output plot1 weight.mol \
		gertest lamtest verzerr

	exeinto /opt/${PN}
	local bins=( bgmn makegeq geomet teil eflech )
	doexe "${bins[@]}"

	local b
	for b in "${bins[@]}"; do
		cat > "${T}/${b}" <<-EOF || die
			#!/bin/sh
			export EFLECH="\${EFLECH:-/opt/${PN}}"
			exec /opt/${PN}/${b} "\$@"
		EOF
		dobin "${T}/${b}"
	done
}
