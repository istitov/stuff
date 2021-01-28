# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit eutils unpacker

DESCRIPTION="A library to allow applications to export a menu into the Unity Menu bar"
HOMEPAGE="http://launchpad.net/libappindicator"
MY_PN="${PN#acestream-}"
SRC_URI="x86? ( mirror://ubuntu/pool/main/liba/libappindicator/${MY_PN}_${PV}-0ubuntu1_i386.deb )
		amd64? ( mirror://ubuntu/pool/main/liba/libappindicator/${MY_PN}_${PV}-0ubuntu1_amd64.deb )"
LICENSE="LGPL-2.1 LGPL-3"
SLOT="3"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-libs/dbus-glib-0.98
	>=dev-libs/glib-2.26
	>=dev-libs/libdbusmenu-12.10.2-r2[gtk]
	dev-libs/acestream-libappindicator
	>=x11-libs/gtk+-2.24.12:2"
DEPEND="${RDEPEND}"

QA_PRESTRIPPED="usr/lib/python2.7/site-packages/appindicator/_appindicator.so"

S="${WORKDIR}"

src_prepare(){
	mv usr/lib/python2.7/dist-packages usr/lib/python2.7/site-packages
}

src_install() {
	cp -R usr/ "${D}"
	# remove trash and fix needed link
	rm "${D}/usr/share/doc/python-appindicator/README"
	rm "${D}/usr/share/doc/python-appindicator/AUTHORS"
	rm "${D}/usr/share/doc/python-appindicator/changelog.Debian.gz"
	rm "${D}/usr/$(get_libdir)/pyshared/python2.7/appindicator/_appindicator.so"
	dosym "${D}usr/$(get_libdir)/python2.7/site-packages/appindicator/_appindicator.so" \
	"/usr/$(get_libdir)/pyshared/python2.7/appindicator/_appindicator.so"
}
