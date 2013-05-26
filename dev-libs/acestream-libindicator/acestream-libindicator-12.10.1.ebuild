# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libindicator/libindicator-12.10.0-r300.ebuild,v 1.2 2012/07/30 20:51:21 ssuominen Exp $

EAPI=5

inherit eutils

DESCRIPTION="A set of symbols and convience functions that all indicators would like to use"
HOMEPAGE="http://launchpad.net/libindicator"
MY_PN="${PN#acestream-}"
SRC_URI="x86? ( mirror://ubuntu/pool/main/libi/${MY_PN}/${MY_PN}7_${PV}-0ubuntu1_i386.deb )
		amd64? ( mirror://ubuntu/pool/main/libi/${MY_PN}/${MY_PN}7_${PV}-0ubuntu1_amd64.deb ) "

LICENSE="GPL-3"
SLOT="2"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-libs/glib-2.22
	>=x11-libs/gtk+-2.24:2"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_prepare(){
	unpack ${A}
	unpack ./data.tar.gz
}

src_install() {
	dolib usr/lib/libindicator.so.7 usr/lib/libindicator.so.7.0.0
}
