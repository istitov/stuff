# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="A simple, lightweight C library for writing XMPP clients"
HOMEPAGE="http://strophe.im/libstrophe/"
SRC_URI="mirror://github/metajack/${PN}/${P}-snapshot.tar.gz"

LICENSE="MIT GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc xml"

RDEPEND="xml? ( dev-libs/libxml2 )
		!xml? ( dev-libs/expat )
		dev-libs/openssl"
DEPEND="${RDEPEND}
		doc? ( app-doc/doxygen )"

S="${WORKDIR}/${P}-snapshot"

src_prepare() {
		epatch "${FILESDIR}"/${PN}-xmpp-conn-disable-tls.patch
		epatch "${FILESDIR}"/${PN}-fix-memory-leaks.patch
		epatch "${FILESDIR}"/${PN}-fix-crash-on-non-latin1.patch
		epatch "${FILESDIR}"/${PN}-xml-escape.patch
}

src_configure() {
		use xml && econf $(use_with xml libxml2)
		# workaround for building with expat support
		use xml || econf
}

src_compile() {
		emake
		if use doc; then
			doxygen || die
		fi
}

src_install() {
		einstall
		use doc && dohtml -r docs/html/*
}
