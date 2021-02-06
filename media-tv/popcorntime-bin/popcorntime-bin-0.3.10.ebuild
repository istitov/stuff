# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils xdg-utils multilib

DESCRIPTION="Watch torrent movies instantly"
HOMEPAGE="http://popcorn.cdnjd.com/"
SRC_URI="x86?   ( https://get.popcorntime.sh/build/Popcorn-Time-${PV}-Linux-32.tar.xz )
	 amd64? ( https://get.popcorntime.sh/build/Popcorn-Time-${PV}-Linux-64.tar.xz )"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="splitdebug strip"

DEPEND=""
RDEPEND="dev-libs/nss
	gnome-base/gconf
	media-fonts/corefonts
	media-libs/alsa-lib
	x11-libs/gtk+:2"

S="${WORKDIR}"

src_install() {
	exeinto /opt/${PN}
	doexe Popcorn-Time libffmpegsumo.so nw.pak package.nw

	dosym /$(get_libdir)/libudev.so.1 /opt/${PN}/libudev.so.0
	make_wrapper ${PN} ./Popcorn-Time /opt/${PN} /opt/${PN} /opt/bin

	domenu "${FILESDIR}"/${PN}.desktop

	doicon -s 256 "${FILESDIR}"/${PN}.png
}

pkg_postinst() {
	xdg-utils_desktop_database_update
}

pkg_postrm() {
	xdg-utils_desktop_database_update
}
