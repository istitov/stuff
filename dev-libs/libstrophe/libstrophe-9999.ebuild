# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

EGIT_REPO_URI="git://github.com/metajack/libstrophe.git"

inherit autotools git-2

DESCRIPTION="A simple, lightweight C library for writing XMPP clients"
HOMEPAGE="http://strophe.im/libstrophe"

LICENSE="MIT GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="xml"

DEPEND="xml? ( dev-libs/libxml2 )
			!xml? ( dev-libs/expat )
			dev-libs/openssl"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P/-/_}"

src_prepare() {
			eautoreconf
}

src_configure() {
			econf $(use_with xml libxml2)
}
