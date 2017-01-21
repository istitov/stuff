# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit autotools eutils

DESCRIPTION="Fork of libstrophe for use with Profanity XMPP Client"
HOMEPAGE="https://github.com/boothj5/libmesode"
SRC_URI="https://github.com/boothj5/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="doc"

RDEPEND="dev-libs/expat
		dev-libs/openssl"
DEPEND="${RDEPEND}
		doc? ( app-doc/doxygen )"

src_prepare() {
		eautoreconf
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
