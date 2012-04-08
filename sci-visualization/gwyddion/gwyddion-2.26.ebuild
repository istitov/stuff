# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-visualization/gwyddion/gwyddion-2.25.ebuild,v 1.6 2011/10/17 15:08:06 jlec Exp $

EAPI=2

PYTHON_DEPEND="python? 2"

inherit eutils fdo-mime gnome2-utils python

DESCRIPTION="A software framework for SPM data analysis"
HOMEPAGE="http://gwyddion.net/"
SRC_URI="http://gwyddion.net/download/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="doc fftw gnome kde nls opengl perl python ruby sourceview xml X"

RDEPEND="
	media-libs/libpng
	x11-libs/cairo
	x11-libs/gtk+:2
	x11-libs/libXmu
	x11-libs/pango
	fftw? ( >=sci-libs/fftw-3 )
	gnome? ( gnome-base/gconf:2 )
	kde? ( >=kde-base/kdelibs-4 )
	opengl? ( virtual/opengl x11-libs/gtkglext )
	perl? ( dev-lang/perl )
	python? ( dev-python/pygtk:2 )
	ruby? ( dev-ruby/narray )
	sourceview? ( x11-libs/gtksourceview:2.0 )
	xml? ( dev-libs/libxml2:2 )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( dev-util/gtk-doc )"

pkg_setup() {
	use python && python_set_active_version 2
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-libpng15.patch
}

src_configure() {
	econf \
		--disable-desktop-file-update \
		--disable-rpath \
		--enable-library-bloat \
		--enable-plugin-proxy \
		$(use_enable doc gtk-doc) \
		$(use_enable nls) \
		$(use_enable python pygwy) \
		$(use_with perl) \
		$(use_with python) \
		$(use_with ruby) \
		$(use_with fftw fftw3) \
		$(use_with opengl gl) \
		$(use_with sourceview gtksourceview) \
		$(use_with xml spml) \
		$(use_with X x) \
		$(use_with kde kde4-thumbnailer)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
	use python && dodoc modules/pygwy/README.pygwy
}

pkg_postinst() {
	use gnome && gnome2_gconf_install
	fdo-mime_desktop_database_update
}

pkg_prerm() {
	use gnome && gnome2_gconf_uninstall
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
