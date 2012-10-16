# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

EGIT_REPO_URI="git://github.com/metajack/libstrophe.git"

inherit autotools eutils git-2

DESCRIPTION="A simple, lightweight C library for writing XMPP clients"
HOMEPAGE=""

LICENSE="MIT GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="doc xml"

RDEPEND="xml? ( dev-libs/libxml2 )
		!xml? ( dev-libs/expat )
		dev-libs/openssl"
DEPEND="${RDEPEND}
		doc? ( app-doc/doxygen )"

S="${WORKDIR}/${P/-/_}"

src_prepare() {
		epatch "${FILESDIR}"/${PN}-fix-build-libxml2.patch
		eautoreconf
}

src_configure() {
		econf $(use_with xml libxml2)
}

src_compile() {
		emake
		if use doc; then
			doxygen || die
		fi
}

src_install() {
		einstall
		dodoc LICENSE.txt README.markdown
		use doc && dohtml -r docs/html/*
}
