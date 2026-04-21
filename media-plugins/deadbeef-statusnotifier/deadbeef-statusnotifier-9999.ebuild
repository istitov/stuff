# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="StatusNotifier tray plugin for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/vovochka404/deadbeef-statusnotifier-plugin"
EGIT_REPO_URI="https://github.com/vovochka404/deadbeef-statusnotifier-plugin.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""
IUSE="+gtk3 gtk2"
REQUIRED_USE="|| ( gtk2 gtk3 )"

DEPEND="
	media-sound/deadbeef
	dev-libs/libdbusmenu:=
	gtk2? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
"
RDEPEND="${DEPEND}"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
"

src_configure() {
	local mycmakeargs=(
		-DUSE_GTK=$(usex gtk2)
		-DUSE_GTK3=$(usex gtk3)
		-DLIBDIR="$(get_libdir)"
	)
	cmake_src_configure
}
