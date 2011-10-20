# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit autotools

DESCRIPTION="Ubuntu's scrollbars"
HOMEPAGE="https://launchpad.net/ayatana-scrollbar"
SRC_URI="http://launchpad.net/ayatana-scrollbar/0.2/${PV}/+download/${PN}-${PV}.tar.gz"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc64 ~sparc ~x86"
IUSE="+gtk2"

CDEPEND=""
DEPEND=">=x11-libs/gtk+-2.24.6[overlay]"
RDEPEND="${DEPEND}"

src_configure(){
	if use gtk2;then 
	  econf --with-gtk=2
	else
	  econf --with-gtk=3
	fi
	
}
src_install(){
  if use gtk2;then
	insinto /usr/lib/
	doins os/.libs/liboverlay-scrollbar-0.2.so.0.0.10
	dosym /usr/lib/liboverlay-scrollbar-0.2.so.0.0.10 /usr/lib/liboverlay-scrollbar-0.2.so.0 
  else
	insinto /usr/lib/
	doins os/.libs/liboverlay-scrollbar3-0.2.so.0.0.10
	dosym /usr/lib/liboverlay-scrollbar3-0.2.so.0.0.10 /usr/lib/liboverlay-scrollbar3-0.2.so.0 
  fi
  
  mv data/81overlay-scrollbar data/overlay-scrollbar.sh
  insinto /etc/profile.d/
  doins data/overlay-scrollbar.sh
}