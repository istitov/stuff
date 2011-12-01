# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

<<<<<<< HEAD
inherit multilib

=======
>>>>>>> 5996721b55904d7294a4580bde1b5fa90a170c0d
DESCRIPTION="A small plugin for LibreOffice to export the menus from the application into Unity's menubar."
HOMEPAGE="https://launchpad.net/lo-menubar"
SRC_URI=" x86? ( https://launchpad.net/ubuntu/+source/${PN}/${PV}-0ubuntu3/+build/2774800/+files/${PN}_${PV}-0ubuntu3_i386.deb )
		  amd64? ( https://launchpad.net/ubuntu/+source/${PN}/${PV}-0ubuntu3/+build/2774798/+files/${PN}_${PV}-0ubuntu3_amd64.deb )"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

CDEPEND=""
DEPEND="|| ( app-office/libreoffice-bin app-office/libreoffice )"
RDEPEND="${DEPEND}"

S="${WORKDIR}"
QA_PRESTRIPPED="/usr/$(get_libdir)/libreoffice/share/extensions/menubar/Linux_x86/menubar.uno.so"
src_prepare(){
<<<<<<< HEAD
  unpack ${A}
  unpack ./data.tar.gz
}
src_install(){
 insinto /usr/$(get_libdir)/libreoffice/share/extensions/
 doins -r usr/lib/libreoffice/share/extensions/*
=======
	unpack ${A}
	unpack ./data.tar.gz
	mkdir -p ${WORKDIR}/tmp/usr/lib/libreoffice/share/extensions/
}
src_install(){
	dodir -R usr/lib/libreoffice/share/extensions/menubar ${WORKDIR}/tmp/usr/$(get_libdir)/libreoffice/share/extensions/
	doins -R ${WORKDIR}/tmp/* "${D}"
>>>>>>> 5996721b55904d7294a4580bde1b5fa90a170c0d
}
