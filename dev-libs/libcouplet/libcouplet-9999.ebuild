# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

EGIT_REPO_URI="git://github.com/pasis/libcouplet.git"

inherit libtool autotools eutils git-2

DESCRIPTION="Fork of libstrophe - a simple, lightweight C library for writing XMPP clients"
HOMEPAGE="https://github.com/pasis/libcouplet"

LICENSE="MIT GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="doc xml"

RDEPEND="xml? ( dev-libs/libxml2 )
		!xml? ( dev-libs/expat )
		dev-libs/openssl"
DEPEND="${RDEPEND}
		doc? ( app-doc/doxygen )
		virtual/pkgconfig"

S="${WORKDIR}/${P/-/_}"

src_prepare() {
		elibtoolize
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
