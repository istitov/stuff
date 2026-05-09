# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools subversion xdg

DESCRIPTION="Framework for Scanning Mode Microscopy data analysis"
HOMEPAGE="https://gwyddion.net/"
ESVN_REPO_URI="https://svn.code.sf.net/p/gwyddion/code/trunk/gwyddion"
ESVN_PROJECT="gwyddion-code"

LICENSE="GPL-2"
SLOT="0"
IUSE="bzip2 doc fits jansson hdf5 nls openexr openmp perl python ruby sourceview unique xml X zlib"

# --enable-pygwy is Python 2.7 only (upstream requirement). pygwy's
# C bindings need the python gobject/gtk/gtk.gdk modules at runtime;
# the bundled modules/pygwy/pygtk-embed only ships build-time headers
# and codegen, not the runtime CPython bindings, so system pygtk:2
# (which pulls pygobject:2 and pycairo-python2) is required for a
# working 'import gwy'.
RDEPEND="
	>=dev-libs/glib-2.32
	dev-libs/libzip
	media-libs/libpng:0=
	>=sci-libs/fftw-3.1:3.0=[openmp?]
	virtual/libiconv
	virtual/libintl
	x11-libs/cairo
	>=x11-libs/gtk+-2.18:2
	x11-libs/libXmu
	x11-libs/pango
	bzip2? ( app-arch/bzip2 )
	fits? ( sci-libs/cfitsio[bzip2?] )
	jansson? ( dev-libs/jansson )
	hdf5? ( sci-libs/hdf5:=[hl,zlib?] )
	openexr? ( media-libs/openexr:= )
	perl? ( dev-lang/perl:= )
	python? (
		dev-lang/python:2.7
		dev-python/pygtk:2
		dev-python/pygobject:2
		dev-python/pycairo-python2
	)
	ruby? ( dev-ruby/narray )
	unique? ( dev-libs/libunique:3 )
	sourceview? ( x11-libs/gtksourceview:2.0 )
	xml? ( dev-libs/libxml2:2= )
	zlib? ( virtual/zlib:= )
"
DEPEND="${RDEPEND}"
# Building from SVN regenerates the pixmap PNGs from src/*.svg at build
# time (release tarballs ship them pre-built). We rewire the rules in
# src_prepare to call rsvg-convert directly instead of inkscape so this
# is a much smaller dep -- not pulled in for 2.70/2.71.
BDEPEND="
	gnome-base/librsvg
	media-gfx/pngcrush
	sys-devel/gettext
	virtual/pkgconfig
	doc? ( dev-util/gtk-doc )
"

PATCHES=(
	"${FILESDIR}/${PN}-2.70-automagic.patch"
)

src_prepare() {
	default
	# Upstream ships config.rpath, a populated po/, and po/POTFILES.in
	# only in release tarballs; the SVN tree expects autogen.sh to lay
	# them down. Do the equivalent here so eautoreconf/make can
	# succeed.
	cp "${BROOT}"/usr/share/gettext/config.rpath . || die
	sh utils/update-potfiles.sh || die
	eautopoint -f

	# Rewire pixmaps/Makefile.am to render SVGs via rsvg-convert instead
	# of inkscape. Each rule body resolves to:
	#   $(INKSCAPE_EXPORT) --export-width=N --export-height=N \
	#       $(INKSCAPE_EXPORT_PNGFILE)="OUT.png" "IN.svg"
	# After our seds it becomes:
	#   rsvg-convert --width=N --height=N --output="OUT.png" "IN.svg"
	sed -i \
		-e 's|^INKSCAPE_EXPORT = .*$|INKSCAPE_EXPORT = rsvg-convert|' \
		-e 's|^INKSCAPE_EXPORT_PNGFILE = .*$|INKSCAPE_EXPORT_PNGFILE = --output|' \
		-e 's|--export-width=|--width=|g' \
		-e 's|--export-height=|--height=|g' \
		pixmaps/Makefile.am || die "rsvg-convert rewrite failed"

	eautoreconf
}

# 3D OpenGL rendering is not built: it requires deprecated GTK-2
# x11-libs/gtkglext, which has been removed from ::gentoo.
src_configure() {
	# hack for bug 741840
	use doc && export GTK_DOC_PATH=/usr/share/gtk-doc

	econf \
		--enable-maintainer-mode \
		--disable-rpath \
		--without-kde4-thumbnailer \
		$(use_enable doc gtk-doc) \
		$(use_enable openmp) \
		$(use_enable nls) \
		$(use_enable python pygwy) \
		$(use_with python) \
		$(use_with bzip2) \
		$(use_with fits cfitsio) \
		$(use_with hdf5) \
		$(use_with jansson) \
		$(use_with perl) \
		$(use_with ruby) \
		$(use_with openexr exr) \
		--without-gl \
		$(use_with sourceview gtksourceview) \
		$(use_with unique) \
		$(use_with xml libxml2) \
		$(use_with X x) \
		$(use_with zlib) \
		--with-zip=libzip
}

src_install() {
	default
	use python && dodoc modules/pygwy/README.pygwy
	find "${ED}" -type f -name "*.la" -delete || die
}
