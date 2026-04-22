# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit autotools python-single-r1 xdg

DESCRIPTION="Framework for Scanning Mode Microscopy data analysis (3.x unstable)"
HOMEPAGE="https://gwyddion.net/"
SRC_URI="https://gwyddion.net/download/${PV}/gwyddion-${PV}.tar.xz -> ${P}.tar.xz"
S="${WORKDIR}/gwyddion-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bzip2 doc fits hdf5 json nls openexr openmp python webp X xml"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

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
	python? ( ${PYTHON_DEPS} )
	webp? ( media-libs/libwebp:= )
	X? ( x11-libs/libXmu )
	xml? ( dev-libs/libxml2:2= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? ( dev-util/gtk-doc )
"

PATCHES=(
	"${FILESDIR}/${P}-automagic.patch"
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	use doc && export GTK_DOC_PATH=/usr/share/gtk-doc
	use python && export PYTHON="${PYTHON}"

	econf \
		--disable-introspection \
		--disable-rpath \
		$(use_enable doc gtk-doc) \
		$(use_enable nls) \
		$(use_enable openmp) \
		$(use_with bzip2) \
		$(use_with fits cfitsio) \
		$(use_with hdf5) \
		$(use_with json json-glib) \
		$(use_with openexr exr) \
		$(use_with python) \
		$(use_with webp) \
		$(use_with X x) \
		$(use_with xml libxml2) \
		--with-zip=libzip
}

src_install() {
	default
	find "${ED}" -type f -name "*.la" -delete || die
}
