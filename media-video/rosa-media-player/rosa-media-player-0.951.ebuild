# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils qt4

DESCRIPTION="ROSA Media Player"
HOMEPAGE="http://www.rosalab.ru/"
SRC_URI="http://svn.mandriva.com/svn/packages/cooker/${PN}/current/SOURCES/${PN}-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nsplugin"

RDEPEND="media-video/mplayer"
DEPEND="${RDEPEND}
	dev-libs/glib
	x11-libs/qt-core:4
	x11-libs/qt-gui:4"

src_compile() {
  emake || die
  mv Makefile Makefile-player  
  
  if use nsplugin;then
	eqmake4 rosampcore.pro
	emake || die
  fi
}
src_install() {
  emake --makefile=Makefile-player PREFIX=/usr DESTDIR="${D}" install || die
  if use nsplugin;then
	mkdir -p ${D}usr/lib/
	cp -R build/librosampcore.so* ${D}usr/lib/
  fi
}
