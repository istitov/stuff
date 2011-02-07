# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libjpeg-turbo/libjpeg-turbo-1.0.90.1.ebuild,v 1.4 2011/01/19 21:09:27 ssuominen Exp $

EAPI=2
inherit autotools libtool toolchain-funcs

DESCRIPTION="MMX, SSE, and SSE2 SIMD accellerated jpeg library"
HOMEPAGE="http://sourceforge.net/projects/libjpeg-turbo/"
SRC_URI="http://dev.gentoo.org/~anarchy/dist/${P}.tar.bz2
	mirror://debian/pool/main/libj/libjpeg8/libjpeg8_8b-1.debian.tar.gz"

LICENSE="as-is LGPL-2.1 wxWinLL-3.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs"

RDEPEND="media-libs/jpeg:0"
DEPEND="${RDEPEND}
	dev-lang/nasm"

S=${WORKDIR}/${PN}

src_prepare() {
	eautoreconf -fiv
	elibtoolize
}

src_configure() {
	econf \
		--with-jpeg8 \
		--disable-dependency-tracking \
		$(use_enable static-libs static)
}

src_compile() {
	emake || die

	cd ../debian/extra || die
	emake CC="$(tc-getCC)" CFLAGS="${LDFLAGS} ${CFLAGS}" || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc BUILDING.txt ChangeLog.txt example.c README-turbo.txt
	find "${D}" -name '*.la' -delete

	cd ../debian/extra || die
	emake DESTDIR="${D}" prefix=/usr install || die
}
