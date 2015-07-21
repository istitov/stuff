# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"

inherit autotools eutils gnome2

DESCRIPTION="An indicator to host the menus from an application."
HOMEPAGE="https://launchpad.net/indicator-appmenu"
SRC_URI="http://launchpad.net/${PN}/0.3/${PV}/+download/${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="+gtk2 gtk3 nls"

RDEPEND=">=dev-libs/glib-2.18:2
	>=x11-libs/gtk+-2.12:2
	gtk3? (
	  >=x11-libs/gtk+-3.2.1:3
	  >=x11-libs/libwnck-3.2.1 )
	>=dev-libs/dbus-glib-0.76
	>=gnome-base/gnome-panel-2
	>=gnome-base/gconf-2
	>=dev-libs/libindicator-0.4.1
	>=dev-libs/libdbusmenu-0.5.0[test]
	gnome-extra/indicator-applet"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? ( dev-util/intltool )
	x11-libs/bamf"

pkg_setup() {
	G2CONF="$(use_enable nls)
		--disable-dependency-tracking"
	DOCS="AUTHORS"
}

src_prepare() {
	gnome2_src_prepare
	eautoreconf
}
src_configure() {
	if use gtk2;then
	econf --with-gtk=2
	fi

	if use gtk3;then
	mkdir gtk3-hack
	cp -R * gtk3-hack &>/dev/null
	cd gtk3-hack

	econf \
		--with-gtk=3 \
		--libexec=/usr/local/libexec
	fi
}

src_compile(){
	if use gtk2;then
	emake || die
	fi

	if use gtk3;then
	cd gtk3-hack
	emake || die
	fi
}
src_install() {
	if use gtk2;then
	make -j3 DESTDIR="${D}" 'scrollkeeper_localstate_dir="${D}"/var/lib/scrollkeeper ' install || die "make install failed"
	fi

	if use gtk3;then
	  cd gtk3-hack
	  make -j3 DESTDIR="${D}" 'scrollkeeper_localstate_dir="${D}"/var/lib/scrollkeeper ' install || die "make install failed"
	fi
	dodoc AUTHORS || die "dodoc failed"
}
