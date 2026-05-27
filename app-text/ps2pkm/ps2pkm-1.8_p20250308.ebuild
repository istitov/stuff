# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic

DESCRIPTION="Tool that converts a PostScript type1 font into a corresponding TeX PK font"
HOMEPAGE="https://tug.org/texlive/"
# 2025 hardcoded in the historic URL; bump on TL2026 adoption.
SRC_URI="
	https://mirrors.ctan.org/systems/texlive/Source/texlive-${PV#*_p}-source.tar.xz
	https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/texlive-${PV#*_p}-source.tar.xz
	https://dev.gentoo.org/~flow/distfiles/texlive/texlive-${PV#*_p}-source.tar.xz
"
S="${WORKDIR}/texlive-${PV#*_p}-source/texk/ps2pk"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=">=dev-libs/kpathsea-6.2.1:="
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

DOCS=( "ChangeLog" "CHANGES.type1" "README" "README.14m" "README.type1" )

src_configure() {
	# bug #944098
	append-cflags -std=gnu17

	econf \
		--with-system-kpathsea
}
