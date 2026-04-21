# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="JACK output plugin for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/tokiclover/deadbeef-plugins-jack"
EGIT_REPO_URI="https://github.com/tokiclover/deadbeef-plugins-jack.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""

DEPEND="
	media-sound/deadbeef
	virtual/jack
"
RDEPEND="${DEPEND}"

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe *.so
}
