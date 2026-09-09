# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

COMMIT="ab115d9ac1a02ddde79c997cd6a0a57a7cabde74"

DESCRIPTION="Quick-search widget for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/cboxdoerfer/ddb_quick_search"
SRC_URI="https://github.com/cboxdoerfer/ddb_quick_search/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/ddb_quick_search-${COMMIT}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~arm64"
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
