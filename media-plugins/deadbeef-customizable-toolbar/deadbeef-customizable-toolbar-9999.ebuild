# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Customizable toolbar widget for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/kravich/ddb_customizabletb"
EGIT_REPO_URI="https://github.com/kravich/ddb_customizabletb.git"

LICENSE="GPL-3+"
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

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe *.so
}
