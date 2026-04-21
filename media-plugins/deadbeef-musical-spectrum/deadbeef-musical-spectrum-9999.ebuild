# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Musical spectrum visualization plugin for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/cboxdoerfer/ddb_musical_spectrum"
EGIT_REPO_URI="https://github.com/cboxdoerfer/ddb_musical_spectrum.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

DEPEND="
	media-sound/deadbeef
	sci-libs/fftw:3.0
"
RDEPEND="${DEPEND}"

src_compile() {
	emake gtk3
}

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe gtk3/*.so
}
