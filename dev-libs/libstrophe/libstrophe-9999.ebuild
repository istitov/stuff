# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_REPO_URI="https://github.com/strophe/libstrophe.git"

inherit autotools git-r3

DESCRIPTION="A simple, lightweight C library for writing XMPP clients"
HOMEPAGE="http://strophe.im/libstrophe/"

LICENSE="MIT GPL-3"
SLOT="0"
IUSE="doc +expat"

RDEPEND="expat? ( dev-libs/expat )
		!expat? ( dev-libs/libxml2:2 )
		dev-libs/openssl:0="
DEPEND="${RDEPEND}
		doc? ( app-doc/doxygen )"

DOCS=( GPL-LICENSE.txt LICENSE.txt MIT-LICENSE.txt README.markdown ChangeLog )

src_prepare() {
		default
		eautoreconf
}

src_configure() {
		econf $(use_with !expat libxml2)
}

src_compile() {
		default
		if use doc; then
			doxygen || die
			HTML_DOCS=( docs/html/* )
		fi
}
