# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libdbusmenu/libdbusmenu-0.3.16-r2.ebuild,v 1.1 2011/02/07 09:56:46 tampakrap Exp $

EAPI=3

inherit autotools eutils versionator virtualx

MY_MAJOR_VERSION="$(get_version_component_range 1-2)"
if version_is_at_least "${MY_MAJOR_VERSION}.50" ; then
	MY_MAJOR_VERSION="$(get_major_version).$(($(get_version_component_range 2)+1))"
fi

DESCRIPTION="Library to pass menu structure across DBus"
HOMEPAGE="https://launchpad.net/dbusmenu"
SRC_URI="http://launchpad.net/dbusmenu/0.5/${PV}/+download/libdbusmenu-${PV}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk gtk3 introspection +test vala"

RDEPEND="dev-libs/glib:2
	dev-libs/dbus-glib
	dev-libs/libxml2:2
	gtk3? ( x11-libs/gtk+:3 )
	gtk? ( x11-libs/gtk+:2 )
	>=dev-libs/json-glib-0.13.4"
DEPEND="${RDEPEND}
	introspection? ( >=dev-libs/gobject-introspection-0.6.7 )
	test? (
		dev-libs/json-glib[introspection=]
		dev-util/dbus-test-runner
	)
	vala? ( dev-lang/vala:0 )
	dev-util/intltool
	dev-util/pkgconfig
	>=dev-libs/atk-2.1.0
	>=x11-libs/pango-1.29
	app-text/gnome-doc-utils"
	
S="${WORKDIR}/libdbusmenu-${PV}"

pkg_setup() {
	if use vala && use !introspection ; then
		eerror "Vala bindings (USE=vala) require introspection support (USE=introspection)"
		die "Vala bindings (USE=vala) require introspection support (USE=introspection)"
	fi
}

src_prepare() {
	sed -e 's:-Werror::g' -i libdbusmenu-glib/Makefile.am libdbusmenu-gtk/Makefile.am || die "sed failed"
	eautoreconf
}

src_configure() {
  if use gtk;then
  econf \
	--with-gtk=2 \
	$(use_enable introspection) \
	$(use_enable test tests) \
	$(use_enable vala)
  fi
  
  if use gtk3;then
	mkdir gtk3-hack
	cp -R * gtk3-hack &>/dev/null
	cd gtk3-hack

	econf \
		--with-gtk=3 \
		$(use_enable introspection) \
		$(use_enable test tests) \
		$(use_enable vala) \
		--prefix=/usr/local \
		--mandir=/usr/local/share \
		--infodir=/usr/local/share \
		--datadir=/usr/local/share \
		--includedir=/usr/local/include
  fi
  
}

src_test() {
	Xemake check || die "testsuite failed"
}
src_compile(){
  emake
  if use gtk3;then
  cd gtk3-hack
  emake
  fi
}
src_install() {
	if use gtk;then
	emake DESTDIR="${ED}" install || die "make install failed"
	fi
	
	if use gtk3;then
	  cd gtk3-hack
	  emake DESTDIR="${ED}" install || die "make install failed"
	  mkdir -p ${D}/usr/lib/pkgconfig
	  mv libdbusmenu-gtk/dbusmenu-gtk3-0.4.pc ${D}/usr/lib/pkgconfig/dbusmenu-gtk3-0.4.pc
	fi
	dodoc AUTHORS || die "dodoc failed"
}
