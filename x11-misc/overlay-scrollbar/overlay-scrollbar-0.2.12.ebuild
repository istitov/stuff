# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit autotools multilib

DESCRIPTION="Ubuntu's scrollbars"
HOMEPAGE="https://launchpad.net/ayatana-scrollbar"
SRC_URI="http://launchpad.net/ayatana-scrollbar/0.2/${PV}/+download/${PN}-${PV}.tar.gz"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc64 ~sparc ~x86"
IUSE="+gtk2 gtk3"

CDEPEND=""
DEPEND="gtk2? ( x11-libs/gtk+:2[overlay] ) 
		gtk3? ( x11-libs/gtk+:3[overlay] )"
RDEPEND="${DEPEND}"

src_configure(){
  if use gtk2;then
	econf --with-gtk=2
  fi

  if use gtk3;then
	mkdir gtk3-hack
	cp -R * gtk3-hack
	cd gtk3-hack
	econf --with-gtk=3
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
	insinto /usr/$(get_libdir)/
	doins os/.libs/liboverlay-scrollbar-0.2.so.0.0.12
	dosym /usr/$(get_libdir)/liboverlay-scrollbar-0.2.so.0.0.12 /usr/$(get_libdir)/liboverlay-scrollbar-0.2.so.0 
  fi
  
  if use gtk3;then
	insinto /usr/$(get_libdir)/
	doins gtk3-hack/os/.libs/liboverlay-scrollbar3-0.2.so.0.0.12
	dosym /usr/$(get_libdir)/liboverlay-scrollbar3-0.2.so.0.0.12 /usr/$(get_libdir)/liboverlay-scrollbar3-0.2.so.0 
  fi
  
  mv data/81overlay-scrollbar data/overlay-scrollbar.sh
  insinto /etc/profile.d/
  doins data/overlay-scrollbar.sh
}