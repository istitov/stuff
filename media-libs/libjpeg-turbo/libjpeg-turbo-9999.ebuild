# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libjpeg-turbo/libjpeg-turbo-9999.ebuild,v 1.1 2010/12/07 20:50:22 megabaks Exp $

EAPI="3"

inherit libtool subversion 

DESCRIPTION="MMX, SSE, and SSE2 SIMD accellerated jpeg library"
HOMEPAGE="http://sourceforge.net/projects/libjpeg-turbo/"
ESVN_REPO_URI="https://libjpeg-turbo.svn.sourceforge.net/svnroot/libjpeg-turbo/trunk/"

LICENSE="as-is LGPL-2.1 wxWinLL-3.1"
SLOT="0"
KEYWORDS=""
IUSE="static-libs"

DEPEND="dev-lang/nasm"

S="${WORKDIR}/${P}/"

src_prepare() {
	autoreconf -fiv
}

src_configure() {
	econf \
		--with-jpeg8 \
		--disable-dependency-tracking \
		$(use_enable static-libs static)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc BUILDING.txt ChangeLog.txt example.c README-turbo.txt
	find "${D}" -name '*.la' -delete
}
