# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

EGIT_REPO_URI="git://github.com/boothj5/libmesode.git"

inherit autotools eutils git-2

DESCRIPTION="Fork of libstrophe for use with Profanity XMPP Client"
HOMEPAGE="https://github.com/boothj5/libmesode"

LICENSE="MIT GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="doc"

RDEPEND="dev-libs/expat
		dev-libs/openssl"
DEPEND="${RDEPEND}
		doc? ( app-doc/doxygen )"

S="${WORKDIR}/${P/-/_}"

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
		dodoc LICENSE.txt README.markdown
		use doc && dohtml -r docs/html/*
}
