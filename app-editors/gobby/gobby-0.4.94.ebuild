# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/gobby/gobby-0.4.94.ebuild,v 1.1 2011/04/30 09:50:35 xarthisius Exp $

EAPI=5

inherit eutils gnome2-utils

DESCRIPTION="GTK-based collaborative editor"
HOMEPAGE="http://gobby.0x539.de/"
SRC_URI="http://releases.0x539.de/${PN}/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0.5"
KEYWORDS="~amd64 ~x86"
IUSE="avahi doc nls gtk3"
MY_PV=0.5

RDEPEND="
	|| ( gtk3? ( dev-cpp/gtkmm:3.0 ) dev-cpp/gtkmm:2 )
	dev-libs/libsigc++:2
	|| ( gtk3? ( >=net-libs/libinfinity-0.4[gtk3,gtk,avahi?] ) >=net-libs/libinfinity-0.4[-gtk3,gtk,avahi?] )
	|| ( gtk3? ( x11-libs/gtk+:3 ) x11-libs/gtk+:2 )
	dev-cpp/libxmlpp:2.6
	>=net-libs/libgsasl-1.6.1
	x11-libs/gtksourceview:3.0"
DEPEND="${RDEPEND}
	dev-cpp/glibmm:2
	virtual/pkgconfig
	doc? (
		app-text/gnome-doc-utils
		app-text/scrollkeeper
		)
	nls? ( >=sys-devel/gettext-0.12.1 )"

src_configure() {
	econf $(use_enable nls) \
		$(use_with gtk3)
}

src_install() {
	emake DESTDIR="${D}" install || die
	domenu contrib/gobby-${MY_PV}.desktop
	doicon gobby-${MY_PV}.xpm
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
