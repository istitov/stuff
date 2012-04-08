# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit autotools

DESCRIPTION="Application menu module for GTK"
HOMEPAGE="https://launchpad.net/appmenu-gtk"
SRC_URI="http://launchpad.net/${PN}/0.2/${PV}/+download/${PN}-${PV}.tar.gz"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="-alpha ~amd64 -ppc64 -sparc ~x86"
IUSE=""

DEPEND=">=dev-libs/libdbusmenu-0.4.2[gtk]
		x11-libs/gtk+:2[appmenu]"
RDEPEND="${DEPEND}"
src_prepare(){
epatch "${FILESDIR}"/fix.patch
}
src_install(){
	insinto /usr/lib/gtk-2.0/2.10.0/menuproxies/
	doins src/.libs/libappmenu.so
	mv 80appmenu appmenu.sh
	insinto /etc/profile.d/
	doins appmenu.sh
}
