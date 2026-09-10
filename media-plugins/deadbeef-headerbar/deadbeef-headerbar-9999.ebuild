# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3

DESCRIPTION="GTK3 headerbar plugin for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/saivert/ddb_misc_headerbar_GTK3"
EGIT_REPO_URI="https://github.com/saivert/ddb_misc_headerbar_GTK3.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

# Configure requires glib-2.0, gio-2.0, and glib-compile-resources; depend on
# dev-libs/glib directly instead of reaching it through gtk+.
# verified 2026-07-27
DEPEND="
	dev-libs/glib:2
	media-sound/deadbeef
	x11-libs/gtk+:3
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
	eautoreconf
}

src_install() {
	default
	find "${ED}" -type f -name '*.la' -delete || die
}
