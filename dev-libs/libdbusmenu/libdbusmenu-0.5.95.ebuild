# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libdbusmenu/libdbusmenu-0.5.1-r300.ebuild,v 1.3 2011/11/28 22:37:34 zmedico Exp $

EAPI=4

PN_vala_version=0.14

inherit virtualx multilib

DESCRIPTION="Library to pass menu structure across DBus"
HOMEPAGE="https://launchpad.net/dbusmenu"
SRC_URI="http://launchpad.net/dbusmenu/0.6/${PV}/+download/${P}.tar.gz"

LICENSE="LGPL-2.1 LGPL-3"
SLOT="3"
KEYWORDS=""
IUSE="gtk gtk3 +introspection test vala"

RDEPEND=">=dev-libs/glib-2.31.16
	dev-libs/dbus-glib
	dev-libs/libxml2
	gtk? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
	introspection? ( >=dev-libs/gobject-introspection-0.6.7 )
	!<${CATEGORY}/${PN}-0.5.1-r200"
DEPEND="${RDEPEND}
	test? (
		dev-libs/json-glib[introspection?]
		dev-util/dbus-test-runner
	)
	vala? ( dev-lang/vala:${PN_vala_version}[vapigen] )
	app-text/gnome-doc-utils
	dev-util/intltool
	dev-util/pkgconfig"

src_prepare() {
	# Drop DEPRECATED flags, bug #391103
	sed -i \
		-e 's:-D[A-Z_]*DISABLE_DEPRECATED:$(NULL):g' \
		{libdbusmenu-{glib,gtk},tests}/Makefile.{am,in} configure{,.ac} || die
}

src_configure() {
	export VALA_API_GEN="$(type -P vapigen-${PN_vala_version})"

	if use gtk;then
	econf \
		--docdir=/usr/share/doc/${PF} \
		--disable-static \
		$(use_enable gtk) \
		--disable-dumper \
		$(use_enable introspection) \
		$(use_enable test tests) \
		$(use_enable vala vala) \
		--with-html-dir=/usr/share/doc/${PF} \
		--with-gtk=2
	fi

	if use gtk3;then
		mkdir gtk3-hack
		cp -R * gtk3-hack &>/dev/null
		cd gtk3-hack
	  econf \
		--with-gtk=3 \
		--disable-static \
		--disable-dumper \
		$(use_enable gtk) \
		$(use_enable introspection) \
		$(use_enable test tests) \
		$(use_enable vala vala) \
		--prefix=/usr/local \
		--mandir=/usr/local/share \
		--infodir=/usr/local/share \
		--datadir=/usr/local/share \
		--includedir=/usr/local/include
	fi
}

src_test() {
	Xemake check
}

src_compile(){
	emake
	if use gtk3;then
	cd gtk3-hack
	emake
	fi
}

src_install() {
	MAKEOPTS="${MAKEOPTS} -j1" emake DESTDIR="${D}" install
	dodoc AUTHORS ChangeLog README
	find "${ED}" -name '*.la' -exec rm -f {} +

	if use gtk3;then
	  cd gtk3-hack
	  emake -j1 DESTDIR="${D}" install
	  dodir /usr/$(get_libdir)/pkgconfig
	  insinto /usr/$(get_libdir)/pkgconfig/
	  doins libdbusmenu-gtk/dbusmenu-gtk3-0.4.pc
	  find "${ED}" -name '*.la' -exec rm -f {} +
	fi
}
