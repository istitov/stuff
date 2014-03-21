# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: bar-overlay/x11-themes/elementary/elementary-1.0.ebuild,v 1.1 2013/12/14 13:01:00 brothermechanic Exp $

EAPI=5

inherit

DESCRIPTION="nitrux OS icons for KDE"
HOMEPAGE="http://nitrux.weebly.com"
SRC_URI="http://nitrux.weebly.com/uploads/1/9/8/8/19881405/nitrux-kde.7z"

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
