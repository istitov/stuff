# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Freetype 2 based TrueType font to TeX's PK format converter"
HOMEPAGE="https://tug.org/texlive/"
# Keep the historic URL year aligned with the TeX Live snapshot.
SRC_URI="
	https://mirrors.ctan.org/systems/texlive/Source/texlive-${PV#*_p}-source.tar.xz
	https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2026/texlive-${PV#*_p}-source.tar.xz
	https://dev.gentoo.org/~flow/distfiles/texlive/texlive-${PV#*_p}-source.tar.xz
"
S="${WORKDIR}/texlive-${PV#*_p}-source/texk/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

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
