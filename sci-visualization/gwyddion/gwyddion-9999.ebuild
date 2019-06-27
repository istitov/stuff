# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit fdo-mime gnome2-utils python-single-r1 subversion autotools

DESCRIPTION="Framework for Scanning Mode Microscopy data analysis"
HOMEPAGE="http://gwyddion.net/"
ESVN_REPO_URI="https://svn.code.sf.net/p/gwyddion/code/trunk/gwyddion"
ESVN_PROJECT="gwyddion-code"
ESVN_BOOTSTRAP="autogen.sh"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="doc fits fftw gnome nls opengl perl python ruby sourceview xml X"

RDEPEND="
	media-libs/libpng:0=
	x11-libs/cairo
	x11-libs/gtk+:2
	x11-libs/libXmu
	x11-libs/pango
	fits? ( sci-libs/cfitsio )
	gnome? ( gnome-base/gconf:2 )
	opengl? ( virtual/opengl x11-libs/gtkglext )
	perl? ( dev-lang/perl:= )
	python? (
		${PYTHON_DEPS}
		dev-python/pygtk:2[${PYTHON_USEDEP}]
	)
	ruby? ( dev-ruby/narray )
	sourceview? ( x11-libs/gtksourceview:2.0 )
	xml? ( dev-libs/libxml2:2 )"

DEPEND="${RDEPEND}
	sci-libs/fftw
	virtual/pkgconfig
	media-gfx/inkscape
	media-gfx/pngcrush
	doc? ( dev-util/gtk-doc )
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

src_configure() { 
	./autogen.sh
	#./configure --prefix="${A}"
	#default
}

src_compile() {
	emake
}

src_install() {
	#default
	make DESTDIR="${D}" install
	#default
	use python && dodoc modules/pygwy/README.pygwy
	#doins -r
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
