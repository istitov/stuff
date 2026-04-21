# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Stereo widener plugin for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/DeaDBeeF-Player/stereo-widener"
EGIT_REPO_URI="https://github.com/DeaDBeeF-Player/stereo-widener.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""

DEPEND="media-sound/deadbeef"
RDEPEND="${DEPEND}"

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe *.so
}
