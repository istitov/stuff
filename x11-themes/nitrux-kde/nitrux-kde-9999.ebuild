# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: bar-overlay/x11-themes/nitrux-kde/nitrux-kde-9999.ebuild,v 2.0 2014/03/28 11:25:00 brothermechanic Exp $

EAPI=5

inherit

DESCRIPTION="nitrux OS icons for KDE"
HOMEPAGE="http://nitrux.weebly.com"
SRC_URI="http://store.nitrux.in/files/NITRUX-KDE.tar.gz"

LICENSE="CC-BY-NC-ND-4"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="-minimal"

RDEPEND="minimal? ( !kde-base/oxygen-icons )"
DEPEND="app-arch/unzip"

RESTRICT="binchecks strip"

S="${WORKDIR}"/NITRUX-KDE

src_install() {
	cd "${WORKDIR}"
	insinto /usr/share/icons
	doins -r ./NITRUX-KDE
}
