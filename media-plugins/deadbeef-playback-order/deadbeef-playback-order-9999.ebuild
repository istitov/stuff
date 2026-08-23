# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="Playback order dropdown widget for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/cboxdoerfer/ddb_playback_order"
EGIT_REPO_URI="https://github.com/cboxdoerfer/ddb_playback_order.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""
IUSE="+gtk3 gtk2"
REQUIRED_USE="|| ( gtk2 gtk3 )"

DEPEND="
	dev-libs/glib:2
	media-sound/deadbeef
	gtk2? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_compile() {
	local make_args=(
		CC="$(tc-getCC)"
		CFLAGS="${CFLAGS} -fPIC -std=c99 -D_GNU_SOURCE"
		LDFLAGS="${LDFLAGS} -shared"
	)

	use gtk2 && emake "${make_args[@]}" gtk2
	use gtk3 && emake "${make_args[@]}" gtk3
}

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	use gtk2 && doexe gtk2/*.so
	use gtk3 && doexe gtk3/*.so
}
