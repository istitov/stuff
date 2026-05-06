# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit autotools python-any-r1 xdg

DESCRIPTION="Framework for Scanning Mode Microscopy data analysis (3.x unstable)"
HOMEPAGE="https://gwyddion.net/"
SRC_URI="https://gwyddion.net/download/${PV}/gwyddion-${PV}.tar.xz -> ${P}.tar.xz"
S="${WORKDIR}/gwyddion-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bzip2 doc fits hdf5 json nls openexr openmp webp X xml"

RDEPEND="
	>=dev-libs/glib-2.68:2
	dev-libs/libzip
	media-libs/libpng:0=
	>=sci-libs/fftw-3.3:3.0=[openmp?]
	virtual/libiconv
	virtual/libintl
	virtual/zlib:=
	>=x11-libs/cairo-1.12
	>=x11-libs/gdk-pixbuf-2.4:2
	>=x11-libs/gtk+-3.24:3
	>=x11-libs/pango-1.10
	app-arch/zstd:=
	bzip2? ( app-arch/bzip2 )
	fits? ( sci-libs/cfitsio[bzip2?] )
	hdf5? ( sci-libs/hdf5:=[hl,zlib] )
	json? ( >=dev-libs/json-glib-1.6 )
	openexr? ( media-libs/openexr:= )
	webp? ( media-libs/libwebp:= )
	X? ( x11-libs/libXmu )
	xml? ( dev-libs/libxml2:2= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
	doc? ( dev-util/gtk-doc )
"

PATCHES=(
	"${FILESDIR}/${P}-automagic.patch"
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	use doc && export GTK_DOC_PATH=/usr/share/gtk-doc

	# --without-python: pygwy is upstream-disabled in 3.x (configure.ac
	# hardcodes ENABLE_PYGWY and HAVE_PYTHON2 to false; the C binding
	# has not been ported to Python 3 / PyGObject). Python is still
	# needed at build time for AM_PATH_PYTHON path substitution.
	econf \
		--disable-introspection \
		--disable-rpath \
		--without-python \
		$(use_enable doc gtk-doc) \
		$(use_enable nls) \
		$(use_enable openmp) \
		$(use_with bzip2) \
		$(use_with fits cfitsio) \
		$(use_with hdf5) \
		$(use_with json json-glib) \
		$(use_with openexr exr) \
		$(use_with webp) \
		$(use_with X x) \
		$(use_with xml libxml2) \
		--with-zip=libzip
}

src_install() {
	default
	find "${ED}" -type f -name "*.la" -delete || die
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "The pygwy Python scripting module is not built: upstream has not"
	elog "yet ported the C binding to Python 3 / PyGObject, and gwyddion"
	elog "3.x hardcodes ENABLE_PYGWY=false in configure.ac. For pygwy"
	elog "scripting, keep using sci-visualization/gwyddion (2.x)."
}
