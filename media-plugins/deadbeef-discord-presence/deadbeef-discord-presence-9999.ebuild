# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Discord Rich Presence plugin for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/kuba160/ddb_discord_presence"
EGIT_REPO_URI="https://github.com/kuba160/ddb_discord_presence.git"
# Pulls in discord-rpc as a submodule.
EGIT_SUBMODULES=( '*' )

LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS=""

DEPEND="media-sound/deadbeef"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-build/cmake
	virtual/pkgconfig
"

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe discord_presence.so
}
