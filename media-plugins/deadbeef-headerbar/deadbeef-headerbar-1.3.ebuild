# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="GTK3 headerbar plugin for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/saivert/ddb_misc_headerbar_GTK3"
SRC_URI="https://github.com/saivert/ddb_misc_headerbar_GTK3/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/ddb_misc_headerbar_GTK3-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

# configure.ac PKG_CHECK_MODULES() both glib-2.0 and gio-2.0, and looks up
# glib-compile-resources via AC_PATH_PROG - each failure is a hard
# AC_MSG_ERROR. All three come from dev-libs/glib; dev-util/glib-utils ships
# only mkenums/genmarshal/gtester-report, not compile-resources. Reaching
# them through x11-libs/gtk+:3 works but is not ours to rely on.
# verified 2026-07-27
DEPEND="
	dev-libs/glib:2
	media-sound/deadbeef
	x11-libs/gtk+:3
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=( "${FILESDIR}/${P}-gcc16-fix-casting.patch" )

src_prepare() {
	default
	eautoreconf
}

src_install() {
	default
	find "${ED}" -type f -name '*.la' -delete || die
}
