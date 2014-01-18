# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT="python2_7"

inherit multilib python-r1 unpacker

DESCRIPTION="ACE Stream Engine"
HOMEPAGE="http://torrentstream.org/"
SRC_URI=" x86? ( http://repo.acestream.org/ubuntu/pool/main/a/${PN}/${PN}_${PV}-1raring4_i386.deb
				 http://stuff.tazhate.com/distfiles/${PN}_${PV}-1raring4_i386.deb )
		amd64? ( http://repo.acestream.org/ubuntu/pool/main/a/${PN}/${PN}_${PV}-1raring4_amd64.deb
				 http://stuff.tazhate.com/distfiles/${PN}_${PV}-1raring4_amd64.deb )"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="dev-python/m2crypto
		dev-python/apsw
		dev-libs/acestream-python-appindicator"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

QA_PRESTRIPPED="usr/bin/acestreamengine
usr/share/acestream/lib/acestreamengine/Core.so
usr/share/acestream/lib/acestreamengine/node.so
usr/share/acestream/lib/acestreamengine/pycompat.so
usr/share/acestream/lib/acestreamengine/Transport.so
usr/share/acestream/lib/acestreamengine/CoreApp.so
usr/share/acestream/lib/acestreamengine/streamer.so"

src_install(){
	cp -R usr "${D}"
}
