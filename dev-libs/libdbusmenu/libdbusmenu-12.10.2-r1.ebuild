# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libdbusmenu/libdbusmenu-0.5.1-r300.ebuild,v 1.3 2011/11/28 22:37:34 zmedico Exp $

EAPI=4

AYATANA_VALA_VERSION=0.16

inherit eutils flag-o-matic

DESCRIPTION="Library to pass menu structure across DBus"
HOMEPAGE="http://launchpad.net/dbusmenu"
SRC_URI="http://launchpad.net/${PN/lib}/${PV%.*}/${PV}/+download/${P}.tar.gz"

LICENSE="LGPL-2.1 LGPL-3"
SLOT="3"
KEYWORDS="~amd64 ~x86"

IUSE="debug gtk +gtk2 +introspection"

RDEPEND=">=dev-libs/glib-2.32
	>=dev-libs/dbus-glib-0.100
	dev-libs/libxml2
	gtk? ( >=x11-libs/gtk+-3.2:3 )
	gtk2? ( x11-libs/gtk+:2 )
	introspection? ( >=dev-libs/gobject-introspection-1 )
	!<${CATEGORY}/${PN}-0.5.1-r200"
DEPEND="${RDEPEND}
	app-text/gnome-doc-utils
	dev-util/intltool
	virtual/pkgconfig
	introspection? ( dev-lang/vala:${AYATANA_VALA_VERSION}[vapigen] )"

src_configure() {
	append-flags -Wno-error #414323

	use introspection && export VALA_API_GEN="$(type -P vapigen-${AYATANA_VALA_VERSION})"
	export HAVE_VALGRIND_FALSE="yes"

	if use gtk;then
	econf \
		--docdir=/usr/share/doc/${PF} \
		--disable-static \
		--disable-silent-rules \
		--disable-scrollkeeper \
		$(use_enable gtk) \
		--disable-dumper \
		--disable-tests \
		$(use_enable introspection) \
		$(use_enable introspection vala) \
		$(use_enable debug massivedebugging) \
		--with-html-dir=/usr/share/doc/${PF}/html \
		--with-gtk=3
	fi

	if use gtk2;then
		mkdir gtk2-hack
		cp -R * gtk2-hack &>/dev/null
		cd gtk2-hack
		econf \
			--docdir=/usr/share/doc/${PF} \
			--disable-static \
			--disable-silent-rules \
			--disable-scrollkeeper \
			$(use_enable gtk) \
			--disable-dumper \
			--disable-tests \
			$(use_enable introspection) \
			$(use_enable introspection vala) \
			$(use_enable debug massivedebugging) \
			--with-html-dir=/usr/share/doc/${PF}/html \
			--with-gtk=2
	fi
}

src_test() { :; } #440192

src_compile(){
	if use gtk;then
		emake
	fi

	if use gtk2;then
		cd gtk2-hack
		emake
	fi
}

src_install() {
	if use gtk;then
		emake -j1 DESTDIR="${D}" install
		dodoc AUTHORS ChangeLog README
	fi

	local a b
	for a in ${PN}-{glib,gtk}; do
		b=/usr/share/doc/${PF}/html/${a}
		[[ -d ${ED}/${b} ]] && dosym ${b} /usr/share/gtk-doc/html/${a}
	done

	prune_libtool_files

	if use gtk2;then
		cd gtk2-hack
		emake -j1 DESTDIR="${D}" install
		prune_libtool_files
	fi
}
