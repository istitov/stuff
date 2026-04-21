# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Replay Gain control widget for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/cboxdoerfer/ddb_replaygain_control"
EGIT_REPO_URI="https://github.com/cboxdoerfer/ddb_replaygain_control.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="+gtk3 gtk2"
REQUIRED_USE="|| ( gtk2 gtk3 )"

DEPEND="
	media-sound/deadbeef
	gtk2? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_compile() {
	use gtk2 && emake gtk2
	use gtk3 && emake gtk3
}

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	use gtk2 && doexe gtk2/*.so
	use gtk3 && doexe gtk3/*.so
}
