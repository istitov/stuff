# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
_PYTHON_ALLOW_PY27=1
PYTHON_COMPAT=( python2_7 )

inherit xdg-utils gnome2-utils python-r1_py2 subversion autotools

DESCRIPTION="Framework for Scanning Mode Microscopy data analysis"
HOMEPAGE="http://gwyddion.net/"
ESVN_REPO_URI="https://svn.code.sf.net/p/gwyddion/code/trunk/gwyddion"
ESVN_PROJECT="gwyddion-code"
ESVN_BOOTSTRAP="autogen.sh"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="fits fftw gnome nls opengl perl python ruby sourceview xml X +hdf5"
addpredict "${EPREFIX}"/usr/share/inkscape/fonts/.uuid.TMP-XXXXXX

RDEPEND="
	>=dev-libs/glib-2.32
	media-libs/libpng:0=
	x11-libs/cairo
	dev-libs/libzip
	>=sci-libs/fftw-3.1:3.0=
	>=x11-libs/gtk+-2.18:2
	x11-libs/libXmu
	x11-libs/pango
	hdf5? ( sci-libs/hdf5 )
	fits? ( sci-libs/cfitsio )
	gnome? ( gnome-base/gconf:2 )
	opengl? ( virtual/opengl x11-libs/gtkglext )
	perl? ( dev-lang/perl:= )
	python? ( dev-lang/python:2.7
		dev-python/pygtk:2[${PYTHON_USEDEP}]
		dev-python/pygments
	)
	ruby? ( dev-ruby/narray )
	sourceview? ( x11-libs/gtksourceview:2.0 )
	xml? ( dev-libs/libxml2:2 )"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	media-gfx/inkscape
	media-gfx/pngcrush
	dev-util/gtk-doc
"
#<=sci-libs/hdf5-1.11
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

src_configure() {
	./autogen.sh
	sed -i -e 's:PYGTK_CODEGENDIR = /lib64/python2.7:PYGTK_CODEGENDIR = /usr/lib64/python2.7:' modules/pygwy/Makefile || die
}

src_compile() {
	emake
}

src_install() {
	make DESTDIR="${D}" install
	use python && dodoc modules/pygwy/README.pygwy
}

pkg_postinst() {
	use gnome && gnome2_gconf_install
	xdg_pkg_postinst
}

pkg_prerm() {
	use gnome && gnome2_gconf_uninstall
}
