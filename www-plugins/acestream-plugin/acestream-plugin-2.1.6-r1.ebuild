# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit multilib unpacker

DESCRIPTION="ACE Stream multimedia plugin for web browsers"
HOMEPAGE="http://torrentstream.org/"
MY_PN="acestream-mozilla-plugin"
SRC_URI=" x86? ( http://repo.acestream.org/ubuntu/pool/main/a/${MY_PN}/${MY_PN}_${PV}-1raring2_i386.deb
		 http://stuff.tazhate.com/distfiles/${MY_PN}_${PV}-1raring2_i386.deb )
	amd64? ( http://repo.acestream.org/ubuntu/pool/main/a/${MY_PN}/${MY_PN}_${PV}-1raring2_amd64.deb
		 http://stuff.tazhate.com/distfiles/${MY_PN}_${PV}-1raring2_amd64.deb )"
RESTRICT="primaryuri"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="~media-video/acestream-player-data-${PV}
	net-p2p/acestream-engine"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

QA_PRESTRIPPED="usr/lib/nsbrowser/plugins/libace_plugin.so"

src_install(){
	mv usr/lib/mozilla usr/lib/nsbrowser
	rm -rf usr/lib/xulrunner-addons usr/lib/mozilla-firefox
	cp -R usr "${D}"
}

pkg_postinst() {
	elog "Acestream plugin installed now."
	elog "The \"Magic player\" extension needed:"
	elog "http://magicplayer.torrentstream.org/?lang=en#/install"
}
