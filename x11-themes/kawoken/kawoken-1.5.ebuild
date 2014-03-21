# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: bar-overlay/x11-themes/kawoken/kawoken-1.5.ebuild,v 1.1 2013/12/14 09:01:00 brothermechanic Exp $

EAPI=5

inherit gnome2-utils

DESCRIPTION="A port of AwOken icon theme on KDE"
HOMEPAGE="https://alecive.deviantart.com/art/"
SRC_URI="https://dl.dropboxusercontent.com/u/8029324/kAwOken-1.5.zip"

LICENSE="CC-BY-NC-SA-3.0 CC-BY-NC-ND-3.0"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="-minimal +orig +dark +white"

RDEPEND="minimal? ( !kde-base/oxygen-icons )"
DEPEND="app-arch/unzip"

RESTRICT="binchecks strip"

MY_PN=kAwOken
S="${WORKDIR}"/${MY_PN}-${PV}

src_install() {
	if use orig; then
		unpack ./${MY_PN}.tar.gz
		mv ./${MY_PN}/Installation_and_Instructions.pdf README.pdf
		dodoc README.pdf
		dodir /usr/share/icons
		mv ./${MY_PN} "${D}"/usr/share/icons/
	fi
	if use dark; then
		unpack ./${MY_PN}Dark.tar.gz
		dodir /usr/share/icons
		mv ./${MY_PN}Dark "${D}"/usr/share/icons/
	fi
	if use white; then
		unpack ./${MY_PN}White.tar.gz
		dodir /usr/share/icons
		mv ./${MY_PN}White "${D}"/usr/share/icons/
	fi
}
