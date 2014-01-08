# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils multilib autotools versionator

DESCRIPTION="Application menu module for GTK"
HOMEPAGE="https://launchpad.net/appmenu-gtk"
MY_REV="20131125"
SRC_URI="https://launchpad.net/ubuntu/+archive/primary/+files/${PN}_0.0.0+${PV}.${MY_REV}.orig.tar.gz"


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

S="${WORKDIR}/${PN}-0.0.0+${PV}.${MY_REV}"

src_prepare(){
	sed 's|-Wall -Woverride|-Wno-error|' -i configure.ac
	eautoreconf
}

src_configure(){
	if use gtk2;then
		sed 's|gtk+-$with_gtk.0|gtk+-2.0|g' -i configure
		econf \
			--with-gtk=gtk2 \
			--disable-schemas-compile
	fi

	if use gtk3;then
		mkdir gtk3-hack
		cp -R * gtk3-hack
		cd gtk3-hack
		sed 's|gtk+-$with_gtk.0|gtk+-3.0|g' -i configure
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
# 	  insinto /usr/$(get_libdir)/gtk-2.0/2.10.0/menuproxies/
# 	  doins src/.libs/libappmenu.so
# 	  mv 80appmenu appmenu_gtk2.sh
# 	  insinto /etc/profile.d/
# 	  doins appmenu_gtk2.sh
	emake DESTDIR="${D}" install
	fi
# 
	if use gtk3;then
		cd gtk3-hack
		emake DESTDIR="${D}" install
	fi
# 
 }
