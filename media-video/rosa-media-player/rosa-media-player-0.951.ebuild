# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils qt4 multilib

DESCRIPTION="ROSA Media Player"
HOMEPAGE="http://www.rosalab.ru/"
SRC_URI="http://svn.mandriva.com/svn/packages/cooker/${PN}/current/SOURCES/${PN}-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nsplugin"
LANGS="ar bg ca cs de el en_GB es_LA es et eu fi fr gl hu it ja ka ko ku lt mk nl pl pt_PT pt pt_BR ro ru sk sl sr sv tr uk vi zh_CN zh_TW"
for lang in ${LANGS}; do
	IUSE+=" linguas_${lang}"
done

RDEPEND="media-video/mplayer"
DEPEND="${RDEPEND}
	dev-libs/glib
	x11-libs/qt-core:4
	x11-libs/qt-gui:4"

src_compile() {
  sed -i '1i#define OF(x) x' \
		src/findsubtitles/quazip/ioapi.{c,h} \
		src/findsubtitles/quazip/{zip,unzip}.h || die
		
  emake || die
  mv Makefile Makefile-player  
  
  if use nsplugin;then
	eqmake4 rosampcore.pro
	emake || die
  fi
}
src_install() {
  for lang in ${LANGS};do
	for x in ${lang};do
	  if ! use linguas_${x}; then
		rm -f "$(find src/translations -type f -name "rosamp_${x}*.qm")"
		rm -rf docs/${x}
	  fi
	done
  done
  
  emake --makefile=Makefile-player PREFIX=/usr DESTDIR="${D}" install || die
  if use nsplugin;then
	dodir usr/$(get_libdir)/
	dolib build/librosampcore.so*
  fi
}
