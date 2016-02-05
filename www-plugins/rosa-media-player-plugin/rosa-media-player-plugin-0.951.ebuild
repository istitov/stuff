# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"

inherit eutils qt4-r2 multilib

DESCRIPTION="ROSA Media Plugin"
HOMEPAGE="http://www.rosalab.ru/"
SRC_URI="http://svn.mandriva.com/svn/packages/cooker/${PN}/current/SOURCES/${PN}-${PV}.tar.gz
		 http://stuff.tazhate.com/distfiles/${PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+mpeg +rm +wmp +divx"
LANGS="ar bg ca cs de el en_GB es_LA es et eu fi fr gl hu it ja ka ko ku lt mk nl pl pt_PT pt pt_BR ro ru sk sl sr sv tr uk vi zh_CN zh_TW"
for lang in ${LANGS}; do
	IUSE+=" linguas_${lang}"
done

RDEPEND="media-video/mplayer"
DEPEND="${RDEPEND}
	dev-libs/glib
	dev-qt/qtcore:4
	dev-qt/qtgui:4"

S="${WORKDIR}"

src_compile() {
	cd rosa-media-player
	eqmake4 rosampcore.pro
	emake

	cd ../rosamp-plugin
	eqmake4 rosamp-plugin-qt.pro
	emake || die
	lrelease rosamp-plugin-qt.pro

	if use "rm"; then
	eqmake4 rosamp-plugin-rm.pro
	emake || die
	fi

	if use "wmp"; then
	eqmake4 rosamp-plugin-wmp.pro
	emake || die
	fi

	if use "mpeg"; then
	eqmake4 rosamp-plugin-smp.pro
	emake || die
	fi

	if use "divx"; then
	eqmake4 rosamp-plugin-dvx.pro
	emake || die
	fi
}
src_install() {
	dodir /usr/$(get_libdir)/nsbrowser/plugins/
	insinto /usr/$(get_libdir)/nsbrowser/plugins/
	doins rosamp-plugin/build/librosa-media-player-plugin-*.so

	dodir usr/$(get_libdir)/
	dolib rosa-media-player/build/librosampcore.so*

	for lang in ${LANGS};do
	for x in ${lang};do
	  if ! use linguas_${x}; then
		rm -f "$(find rosamp-plugin/translations -type f -name "rosamp_plugin_${x}*.qm")"
	  fi
	done
	done

	for i in $(find rosamp-plugin/translations -type f -name "rosamp_plugin_*.qm");do
	dodir /usr/$(get_libdir)/mozilla/plugins/translations
	insinto /usr/$(get_libdir)/mozilla/plugins/translations
	doins ${i}
	done
}
