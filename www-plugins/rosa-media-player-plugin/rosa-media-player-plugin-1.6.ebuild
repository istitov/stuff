# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit eutils qt4-r2 multilib

DESCRIPTION="ROSA Media Player Plugin is designed to use with internet browsers."
HOMEPAGE="http://www.rosalab.ru/"
SRC_URI="http://stuff.tazhate.com/distfiles/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+mpeg +rm +wmp +divx"

RDEPEND="media-video/mplayer"
DEPEND="${RDEPEND}
	dev-libs/glib
	dev-qt/qtcore:4
	dev-qt/qtgui:4"

src_compile() {
	lrelease rosa-media-player-plugin.pro
	cd romp/rosa-media-player
	eqmake4 rosampcore.pro
	emake

	cd ../../rosamp-plugin
	eqmake4 rosamp-plugin-qt.pro
	emake || die

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
	dolib romp/rosa-media-player/build/librosampcore.so*

	dodir /usr/$(get_libdir)/mozilla/plugins/translations
	insinto /usr/$(get_libdir)/mozilla/plugins/translations
	doins translations/rosamp_plugin_*.qm
}
