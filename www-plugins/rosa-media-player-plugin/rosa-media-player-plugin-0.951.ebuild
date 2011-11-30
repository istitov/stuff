# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils qt4 multilib

DESCRIPTION="ROSA Media Plugin"
HOMEPAGE="http://www.rosalab.ru/"
SRC_URI="http://svn.mandriva.com/svn/packages/cooker/${PN}/current/SOURCES/${PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	=media-video/rosa-media-player-${PV}[nsplugin]"

S="${WORKDIR}/rosamp-plugin"

src_compile() {  
  eqmake4 rosamp-plugin-qt.pro
  emake || die
  
  eqmake4 rosamp-plugin-wmp.pro
  emake || die
  
  eqmake4 rosamp-plugin-smp.pro
  emake || die
  
  eqmake4 rosamp-plugin-dvx.pro
  emake || die
  
  eqmake4 rosamp-plugin-rm.pro
  emake || die
}
src_install() {
  dodir usr/$(get_libdir)/nsbrowser/plugins/
  cp -R build/librosa-media-player-plugin-{qt,wmp,smp,dvx,rm}.so ${D}usr/$(get_libdir)/nsbrowser/plugins/
}
