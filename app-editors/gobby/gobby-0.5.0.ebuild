# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils gnome2-utils toolchain-funcs

DESCRIPTION="GTK-based collaborative editor"
HOMEPAGE="https://gobby.github.io/"
SRC_URI="http://releases.0x539.de/${PN}/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0.5"
KEYWORDS="~amd64 ~x86"
IUSE="avahi doc +gtk3 nls"

RDEPEND="dev-cpp/glibmm:2
	gtk3? ( dev-cpp/gtkmm:3.0 )
	!gtk3? ( dev-cpp/gtkmm:2.4 )
	dev-libs/libsigc++:2
	gtk3? ( net-libs/libinfinity:0/0.6[gtk3,avahi?] )
	!gtk3? ( net-libs/libinfinity:0/0.6[gtk,avahi?] )
	gtk3? ( x11-libs/gtk+:3 )
	!gtk3? ( x11-libs/gtk+:2 )
	dev-cpp/libxmlpp:2.6
	gtk3? ( x11-libs/gtksourceview:3.0 )
	!gtk3? ( x11-libs/gtksourceview:2.0 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? (
		>=app-text/gnome-doc-utils-0.9.0
		app-text/scrollkeeper-dtd
		app-text/rarian
		)
	nls? ( >=sys-devel/gettext-0.12.1 )"

src_configure() {
	econf $(use_enable doc scrollkeeper ) \
		$(use_enable nls ) \
		$(use_with gtk3 )
}

src_install() {
	emake DESTDIR="${D}" install || die
	domenu gobby-0.5.desktop
	doicon gobby-0.5.xpm
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
