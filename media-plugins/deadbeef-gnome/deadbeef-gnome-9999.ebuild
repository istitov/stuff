# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Gnome (DBus) multimedia-keys plugin for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/barthez/deadbeef-gnome-mmkeys"
EGIT_REPO_URI="https://github.com/barthez/deadbeef-gnome-mmkeys.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

DEPEND="
	dev-libs/glib:2
	media-sound/deadbeef
"
RDEPEND="${DEPEND}"

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe *.so
}
