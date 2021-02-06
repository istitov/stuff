# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils unpacker

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

src_install() {
	dolib usr/lib/libindicator.so.7 usr/lib/libindicator.so.7.0.0
}
