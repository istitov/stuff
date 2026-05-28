# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Freetype 2 based TrueType font to TeX's PK format converter"
HOMEPAGE="https://tug.org/texlive/"
# 2026 hardcoded in the historic URL; bump on TL2027 adoption.
SRC_URI="
	https://mirrors.ctan.org/systems/texlive/Source/texlive-${PV#*_p}-source.tar.xz
	https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2026/texlive-${PV#*_p}-source.tar.xz
	https://dev.gentoo.org/~flow/distfiles/texlive/texlive-${PV#*_p}-source.tar.xz
"
S="${WORKDIR}/texlive-${PV#*_p}-source/texk/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

# Note about blockers: it is a freetype2 based replacement for ttf2pk and
# ttf2tfm from freetype1, so block freetype1.
# It installs some data that collides with
# dev-texlive/texlive-langcjk-2011[source]. Hope it'd be fixed with 2012,
# meanwhile we can start dropping freetype1.
RDEPEND="
	>=dev-libs/kpathsea-6.2.1
	media-libs/freetype:2
	virtual/zlib:=
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	econf \
		--with-system-kpathsea \
		--with-system-freetype2 \
		--with-system-zlib
}
