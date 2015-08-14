# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit eutils multilib versionator

DESCRIPTION="Application menu module for GTK"
HOMEPAGE="https://launchpad.net/appmenu-gtk"
SRC_URI="http://launchpad.net/${PN}/$(get_version_component_range 1-2)/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="-alpha ~amd64 -ppc64 -sparc ~x86"
IUSE="+gtk2 gtk3"

CDEPEND=""
DEPEND="gtk3? ( || ( >=dev-libs/libdbusmenu-0.6.1[gtk] >=dev-libs/libdbusmenu-0.6.1[gtk3] )
				x11-libs/gtk+:3[appmenu] )
		gtk2? ( >=dev-libs/libdbusmenu-0.6.1[gtk2]
				x11-libs/gtk+:2[appmenu] )"
RDEPEND="${DEPEND}"

src_prepare(){
	epatch "${FILESDIR}/fix.patch"
}

src_configure(){
	if use gtk2;then
	  econf --with-gtk2
	fi

	if use gtk3;then
	  mkdir gtk3-hack
	  cp -R * gtk3-hack
	  cd gtk3-hack
	  econf
	fi
}

src_compile(){
	if use gtk2;then
	  emake
	fi

	if use gtk3;then
	  cd gtk3-hack
	  emake
	fi
}

src_install(){
	if use gtk2;then
	  insinto /usr/$(get_libdir)/gtk-2.0/2.10.0/menuproxies/
	  doins src/.libs/libappmenu.so
	  mv 80appmenu appmenu_gtk2.sh
	  insinto /etc/profile.d/
	  doins appmenu_gtk2.sh
	fi

	if use gtk3;then
	  insinto /usr/$(get_libdir)/gtk-3.0/3.0.0/menuproxies
	  doins gtk3-hack/src/.libs/libappmenu.so
	  mv gtk3-hack/80appmenu-gtk3 gtk3-hack/appmenu_gtk3.sh
	  insinto /etc/profile.d/
	  doins gtk3-hack/appmenu_gtk3.sh
	fi

}
