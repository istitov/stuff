# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit unpacker

DESCRIPTION="ACE Stream HD multimedia player based on VLC"
HOMEPAGE="http://torrentstream.org/"
SRC_URI=" x86? ( http://repo.acestream.org/ubuntu/pool/main/a/${PN}/${PN}_${PV}-1raring2_i386.deb
				 http://stuff.tazhate.com/distfiles/${PN}_${PV}-1raring2_i386.deb )
		amd64? ( http://repo.acestream.org/ubuntu/pool/main/a/${PN}/${PN}_${PV}-1raring2_amd64.deb
				 http://stuff.tazhate.com/distfiles/${PN}_${PV}-1raring2_amd64.deb )"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND=""
DEPEND="media-video/acestream-player-data
		net-p2p/acestream-engine"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_install(){
	cp -R usr "${D}"
}
