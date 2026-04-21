# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="PulseAudio output plugin (async API) for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/saivert/ddb_output_pulse2"
EGIT_REPO_URI="https://github.com/saivert/ddb_output_pulse2.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

DEPEND="
	media-libs/libpulse
	media-sound/deadbeef
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe *.so
}
