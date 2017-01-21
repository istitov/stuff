# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit autotools eutils

DESCRIPTION="A simple, lightweight C library for writing XMPP clients"
HOMEPAGE="http://strophe.im/libstrophe/"
SRC_URI="https://github.com/strophe/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="doc libressl -xml"

RDEPEND="xml? ( dev-libs/libxml2 )
		!xml? ( dev-libs/expat )
		libressl? ( dev-libs/libressl:0= )
		!libressl? ( dev-libs/openssl:0= )"
DEPEND="${RDEPEND}
		doc? ( app-doc/doxygen )"

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
