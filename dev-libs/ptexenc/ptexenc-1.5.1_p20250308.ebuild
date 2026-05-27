# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit libtool

DESCRIPTION="Library for Japanese pTeX providing a better way of handling character encodings"
HOMEPAGE="http://tutimura.ath.cx/ptexlive/?ptexenc"
# 2025 hardcoded in the historic URL because PV's "_p<YYYYMMDD>" date
# format makes the four-digit year non-trivial to extract via Portage
# parameter expansion at SRC_URI time. Bump on TL2026 adoption.
SRC_URI="
	https://mirrors.ctan.org/systems/texlive/Source/texlive-${PV#*_p}-source.tar.xz
	https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/texlive-${PV#*_p}-source.tar.xz
	https://dev.gentoo.org/~flow/distfiles/texlive/texlive-${PV#*_p}-source.tar.xz
"
S="${WORKDIR}/texlive-${PV#*_p}-source/texk/${PN}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="iconv"

DEPEND="
	dev-libs/kpathsea:=
	iconv? ( virtual/libiconv )"
RDEPEND="${DEPEND}"

src_prepare() {
	default

	# https://bugs.gentoo.org/show_bug.cgi?id=377141
	sed -i '/^LIBS/s:@LIBS@:@LIBS@ @KPATHSEA_LIBS@:' Makefile.in || die

	cd "${WORKDIR}/texlive-${PV#*_p}-source" || die
	S="${WORKDIR}/texlive-${PV#*_p}-source" elibtoolize #sane .so versionning on gfbsd
}

src_configure() {
	econf \
		--disable-static \
		--with-system-kpathsea \
		$(use_enable iconv kanji-iconv)
}

src_install() {
	default

	insinto /usr/include/ptexenc
	doins ptexenc/unicode-jp.h
	use iconv && doins ptexenc/kanjicnv.h

	find "${ED}" -name '*.la' -delete || die
}
