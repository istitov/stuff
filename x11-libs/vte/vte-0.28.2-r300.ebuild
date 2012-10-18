# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/vte/vte-0.28.2-r300.ebuild,v 1.7 2011/10/30 17:48:40 armin76 Exp $

EAPI="3"
GCONF_DEBUG="yes"
GNOME_TARBALL_SUFFIX="xz"
GNOME2_LA_PUNT="yes"

inherit autotools eutils gnome2

DESCRIPTION="GNOME terminal widget"
HOMEPAGE="http://git.gnome.org/browse/vte"
SRC_URI="${SRC_URI} mirror://gentoo/introspection.m4.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="debug doc glade +introspection gtk3"

PDEPEND="x11-libs/gnome-pty-helper"
RDEPEND=">=dev-libs/glib-2.26:2
	|| ( gtk3? ( >=x11-libs/gtk+-3.0:3[introspection?] ) >=x11-libs/gtk+-2.20:2[introspection?] )
	>=x11-libs/pango-1.22.0

	sys-libs/ncurses
	x11-libs/libX11
	x11-libs/libXft

	glade? ( >=dev-util/glade-3.9:3.10 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.0 )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	virtual/pkgconfig
	sys-devel/gettext
	doc? ( >=dev-util/gtk-doc-1.13 )"

pkg_setup() {
	# Python bindings are via gobject-introspection
	# Ex: from gi.repository import Vte
	if use gtk3;then
	mygtk="3.0"
	else
	mygtk="2.0"
	fi

	G2CONF="${G2CONF}
		--disable-gnome-pty-helper
		--disable-deprecation
		--disable-maintainer-mode
		--disable-static
		$(use_enable debug)
		$(use_enable glade glade-catalogue)
		$(use_enable introspection)
		--with-gtk=${mygtk}"
	DOCS="AUTHORS ChangeLog HACKING NEWS README"
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.28.0-fix-gdk-targets.patch"

	mv "${WORKDIR}/introspection.m4" "${S}/" || die
	AT_M4DIR="." eautoreconf

	gnome2_src_prepare
}
