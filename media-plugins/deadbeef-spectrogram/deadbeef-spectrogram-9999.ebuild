# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="Spectrogram plugin for DeaDBeeF audio player"
HOMEPAGE="https://github.com/cboxdoerfer/ddb_spectrogram"
EGIT_REPO_URI="https://github.com/cboxdoerfer/ddb_spectrogram.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="
	sci-libs/fftw:3.0
	media-sound/deadbeef"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

src_compile() {
	emake gtk3
}

src_install() {
	insinto /usr/$(get_libdir)/deadbeef
	doins gtk3/ddb_vis_spectrogram_GTK3.so
}
