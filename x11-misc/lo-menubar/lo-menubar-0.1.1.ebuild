# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit multilib unpacker

DESCRIPTION="A small plugin for LibreOffice to export the menus into Unity's menubar."
HOMEPAGE="https://launchpad.net/lo-menubar"
SRC_URI=" x86? ( http://launchpadlibrarian.net/104771746/${PN}_${PV}-0ubuntu1_i386.deb )
	amd64? ( http://launchpadlibrarian.net/104772046/${PN}_${PV}-0ubuntu1_amd64.deb )"
RESTRICT="primaryuri"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND=""
DEPEND="|| ( app-office/libreoffice-bin app-office/libreoffice )"
RDEPEND="${DEPEND}"

S="${WORKDIR}"
QA_PRESTRIPPED="/usr/$(get_libdir)/libreoffice/share/extensions/menubar/Linux_x86/menubar.uno.so"

src_install(){
	insinto /usr/$(get_libdir)/libreoffice/share/extensions/
	doins -r usr/lib/libreoffice/share/extensions/*
}
