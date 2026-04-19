# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools desktop git-r3 xdg

DESCRIPTION="GTK-based collaborative editor"
HOMEPAGE="https://gobby.github.io/"
EGIT_REPO_URI="https://github.com/${PN}/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
IUSE="avahi nls"

RDEPEND="
	>=dev-cpp/gtkmm-3.6.0:3.0
	>=dev-cpp/glibmm-2.39.93:2
	dev-cpp/libxmlpp:2.6
	dev-libs/libsigc++:2
	net-libs/libinfinity:0.7[gtk3,avahi?]
	x11-libs/gtk+:3
	x11-libs/gtksourceview:3.0
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? ( >=sys-devel/gettext-0.12.1 )
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf $(use_enable nls)
}

src_install() {
	default
	domenu gobby-0.5.desktop
	doicon gobby-0.5.xpm
}
