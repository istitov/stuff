# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit autotools eutils

DESCRIPTION="A simple, lightweight C library for writing XMPP clients"
HOMEPAGE="http://strophe.im/libstrophe/"
SRC_URI="https://github.com/strophe/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc xml"

RDEPEND="xml? ( dev-libs/libxml2 )
		!xml? ( dev-libs/expat )
		dev-libs/openssl"
DEPEND="${RDEPEND}
		doc? ( app-doc/doxygen )"

src_prepare() {
		epatch "${FILESDIR}"/${PN}-fix-openssl.patch
		epatch "${FILESDIR}"/${PN}-handle-errors.patch
		epatch "${FILESDIR}"/${PN}-sha1-in-place-op.patch
		eautoreconf
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
