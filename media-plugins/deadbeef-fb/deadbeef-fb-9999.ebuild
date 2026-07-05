# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3

DESCRIPTION="File-browser widget plugin for the DeaDBeeF audio player"
HOMEPAGE="https://gitlab.com/zykure/deadbeef-fb"
EGIT_REPO_URI="https://gitlab.com/zykure/deadbeef-fb.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""

DEPEND="
	media-sound/deadbeef
	x11-libs/gtk+:3
"
RDEPEND="${DEPEND}"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	# We only DEPEND on gtk+:3, so build the GTK3 plugin only. Upstream's
	# configure also builds a GTK2 variant whenever gtk+:2 headers happen
	# to be present, and that variant no longer compiles against modern
	# GTK2 (deprecated GTypeDebugFlags, hard-errored by Makefile.am's
	# -Werror under gcc-16). # verified 2026-07-05
	econf --disable-gtk2
}

src_install() {
	default
	find "${ED}" -type f -name '*.la' -delete || die
}
