# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils unpacker

DESCRIPTION="A library to allow applications to export a menu into the Unity Menu bar"
HOMEPAGE="http://launchpad.net/libappindicator"
MY_PN="${PN#acestream-}"
SRC_URI="x86? ( mirror://ubuntu/pool/main/liba/${MY_PN}/${MY_PN}1_${PV}-0ubuntu1_i386.deb )
		amd64? ( mirror://ubuntu/pool/main/liba/${MY_PN}/${MY_PN}1_${PV}-0ubuntu1_amd64.deb ) "

LICENSE="LGPL-2.1 LGPL-3"
SLOT="3"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-libs/dbus-glib-0.98
	>=dev-libs/glib-2.26
	>=dev-libs/libdbusmenu-12.10.2-r2[gtk]
	dev-libs/acestream-libindicator
	>=x11-libs/gtk+-2.24.12:2"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_install() {
	dolib usr/lib/libappindicator.so.1.0.0 usr/lib/libappindicator.so.1
}
