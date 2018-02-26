# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A simple, lightweight C library for writing XMPP clients"
HOMEPAGE="http://strophe.im/libstrophe/"
SRC_URI="https://github.com/strophe/${PN}/releases/download/${PV}/${P}.tar.bz2"

LICENSE="MIT GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="doc examples libressl -xml"

RDEPEND="xml? ( dev-libs/libxml2 )
		!xml? ( dev-libs/expat )
		libressl? ( dev-libs/libressl:0= )
		!libressl? ( dev-libs/openssl:0= )"
DEPEND="${RDEPEND}
		doc? ( app-doc/doxygen )"

src_configure() {
		econf $(use_with xml libxml2)
}

src_compile() {
		default

		if use doc; then
			doxygen || die
		fi
}

src_install() {
		DOCS="GPL-LICENSE.txt LICENSE.txt MIT-LICENSE.txt README ChangeLog"
		if use doc; then
			HTML_DOCS="docs/html/*"
		fi

		default

		if use examples; then
			docinto examples
			dodoc examples/active.c examples/basic.c examples/bot.c \
				examples/component.c examples/roster.c examples/vcard.c
		fi
}
