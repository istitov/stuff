# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools subversion xdg

DESCRIPTION="Framework for Scanning Mode Microscopy data analysis"
HOMEPAGE="http://gwyddion.net/"
ESVN_REPO_URI="https://svn.code.sf.net/p/gwyddion/code/trunk/gwyddion"
ESVN_PROJECT="gwyddion-code"

LICENSE="GPL-2"
SLOT="0"
IUSE="bzip2 doc fits jansson hdf5 nls openexr openmp perl python ruby sourceview unique xml X zlib"

# --enable-pygwy is Python 2.7 only (upstream requirement); it ships an
# embedded pygtk at modules/pygwy/pygtk-embed so no system pygtk:2 dep
# is needed - configure falls back to it if pkg-config can't find one.
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
	python? ( dev-lang/python:2.7 )
	ruby? ( dev-ruby/narray )
	unique? ( dev-libs/libunique:3 )
	sourceview? ( x11-libs/gtksourceview:2.0 )
	xml? ( dev-libs/libxml2:2= )
	zlib? ( virtual/zlib:= )
"
DEPEND="${RDEPEND}"
# Building from SVN regenerates the pixmap PNGs from src/*.svg at build
# time (release tarballs ship them pre-built), so inkscape + pngcrush
# are hard BDEPENDs here but not for 2.70/2.71.
BDEPEND="
	media-gfx/inkscape
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
