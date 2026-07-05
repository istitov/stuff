# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Discord Rich Presence plugin for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/kuba160/ddb_discord_presence"

# discord-rpc is a git submodule (kuba160's fork) that GitHub's release
# tarball omits; fetch the exact commit pinned at v${PV} and drop it in.
DISCORD_RPC_COMMIT="10ea83ea71f5bf4afb3b0fcbff768a5e84eeeebf"
SRC_URI="
	https://github.com/kuba160/ddb_discord_presence/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/kuba160/discord-rpc/archive/${DISCORD_RPC_COMMIT}.tar.gz -> ${P}-discord-rpc.tar.gz
"
S="${WORKDIR}/ddb_discord_presence-${PV}"

LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="media-sound/deadbeef"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-build/cmake
	virtual/pkgconfig
"

src_prepare() {
	default
	# The release tarball ships an empty discord-rpc submodule dir; drop
	# in the pinned commit's source so `make` can build libdiscord-rpc.a.
	rm -rf discord-rpc || die
	mv "${WORKDIR}/discord-rpc-${DISCORD_RPC_COMMIT}" discord-rpc || die
}

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe discord_presence.so
}
