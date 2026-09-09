# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT="f177bddf5dbd5ccb4e36408903ef05d936aa6885"

DESCRIPTION="Musical spectrum visualization plugin for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/cboxdoerfer/ddb_musical_spectrum"
SRC_URI="https://github.com/cboxdoerfer/ddb_musical_spectrum/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/ddb_musical_spectrum-${COMMIT}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

DEPEND="
	media-sound/deadbeef
	sci-libs/fftw:3.0
	x11-libs/gtk+:3
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=( "${FILESDIR}/${PN}-gcc16.patch" )

src_compile() {
	emake gtk3
}

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe gtk3/*.so
}
