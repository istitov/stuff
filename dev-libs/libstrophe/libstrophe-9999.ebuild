# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

EGIT_REPO_URI="git://github.com/strophe/libstrophe.git"

inherit autotools eutils git-2

DESCRIPTION="A simple, lightweight C library for writing XMPP clients"
HOMEPAGE="http://strophe.im/libstrophe/"

LICENSE="MIT GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="doc -xml"

RDEPEND="xml? ( dev-libs/libxml2 )
		!xml? ( dev-libs/expat )
		dev-libs/openssl"
DEPEND="${RDEPEND}
		doc? ( app-doc/doxygen )"

S="${WORKDIR}/${P/-/_}"

src_prepare() {
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
		dodoc GPL-LICENSE.txt LICENSE.txt MIT-LICENSE.txt README.markdown \
			ChangeLog
		use doc && dohtml -r docs/html/*
}
