# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT="python2_7"

inherit multilib python-r1

DESCRIPTION="ACE Stream Engine"
HOMEPAGE="http://torrentstream.org/"
SRC_URI=" x86? ( http://repo.acestream.org/ubuntu/pool/main/a/${PN}/${PN}_${PV}-1raring6_i386.deb )
		amd64? ( http://repo.acestream.org/ubuntu/pool/main/a/${PN}/${PN}_${PV}-1raring6_amd64.deb )"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="gtk"

DEPEND="dev-python/m2crypto
		dev-python/apsw
		gtk? ( dev-libs/acestream-python-appindicator )"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_prepare(){
	unpack ${A}
	unpack ./data.tar.gz
}

src_install(){
	mv usr/lib/python2.7/dist-packages usr/lib/python2.7/site-packages
	if ! use gtk;then
		sed 's|client_gtk|client_console|' -i usr/bin/acestreamengine-client-gtk
	fi
	cp -R usr "${D}"
}
