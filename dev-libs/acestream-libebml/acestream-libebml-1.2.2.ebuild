# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libebml/libebml-1.2.2.ebuild,v 1.9 2012/05/29 13:32:31 aballier Exp $

EAPI=4

inherit eutils multilib toolchain-funcs

MY_P="${P/acestream-/}"
MY_PN="${PN/acestream-/}"
DESCRIPTION="Extensible binary format library (kinda like XML) for acestream"
HOMEPAGE="http://www.matroska.org/"
SRC_URI="http://www.bunkus.org/videotools/mkvtoolnix/sources/${MY_P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="!<dev-libs/libebml-1.3.0"

S="${WORKDIR}/${MY_P}/make/linux"

src_prepare() {
	epatch "${FILESDIR}"/${MY_PN}-1.2.0-makefile-fixup.patch
	sed -i -e "s:\(DEBUGFLAGS=\)-g :\1:" Makefile || die
}

src_compile() {
	emake \
		prefix="${EPREFIX}/usr" \
		AR="$(tc-getAR)" \
		CC="$(tc-getCC)" \
		CXX="$(tc-getCXX)" \
		sharedlib
}

src_install() {
	dolib libebml.so.3
}
