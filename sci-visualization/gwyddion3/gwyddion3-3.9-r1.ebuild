# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit autotools python-single-r1 xdg

DESCRIPTION="Framework for Scanning Mode Microscopy data analysis (3.x unstable)"
HOMEPAGE="https://gwyddion.net/"
SRC_URI="https://gwyddion.net/download/${PV}/gwyddion-${PV}.tar.xz -> ${PN}-${PV}.tar.xz"
S="${WORKDIR}/gwyddion-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bzip2 doc fits hdf5 introspection json nls openexr openmp python sourceview webp X xml"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	python? ( introspection )
	sourceview? ( python )
"

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
	introspection? ( >=dev-libs/gobject-introspection-1.74 )
	json? ( >=dev-libs/json-glib-1.6 )
	openexr? ( media-libs/openexr:= )
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '>=dev-python/pygobject-3.40[${PYTHON_USEDEP}]')
	)
	sourceview? ( x11-libs/gtksourceview:4 )
	webp? ( media-libs/libwebp:= )
	X? ( x11-libs/libXmu )
	xml? ( dev-libs/libxml2:2= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
	dev-libs/gobject-introspection-common
	doc? ( dev-util/gtk-doc )
"

PATCHES=(
	"${FILESDIR}/${PN}-${PV}-automagic.patch"
)

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	# The three pygwy patches are stored as .patch.bz2 to keep the git
	# tree small (stage-A is 586 KiB of dead-code removal). eapply in
	# EAPI 8 does not auto-decompress, unlike the older epatch eclass;
	# decompress to ${T} and append to PATCHES so default handles them.
	local f decompressed
	for f in "${FILESDIR}/${PN}-${PV}"-pygwy-stage-*.patch.bz2; do
		decompressed="${T}/$(basename "${f%.bz2}")"
		bunzip2 -kc "${f}" > "${decompressed}" || die
		PATCHES+=( "${decompressed}" )
	done
	default
	eautoreconf
}

src_configure() {
	use doc && export GTK_DOC_PATH=/usr/share/gtk-doc

	econf \
		$(use_enable doc gtk-doc) \
		$(use_enable introspection) \
		$(use_enable nls) \
		$(use_enable openmp) \
		$(use_enable python pygwy) \
		$(use_with bzip2) \
		$(use_with fits cfitsio) \
		$(use_with hdf5) \
		$(use_with json json-glib) \
		$(use_with openexr exr) \
		$(use_with python) \
		$(use_with sourceview gtksourceview) \
		$(use_with webp) \
		$(use_with X x) \
		$(use_with xml libxml2) \
		--disable-rpath \
		--with-zip=libzip
}

src_install() {
	default
	find "${ED}" -type f -name "*.la" -delete || die
}

pkg_postinst() {
	xdg_pkg_postinst
	if use python; then
		elog "Pygwy (Python 3 scripting via GObject Introspection) is built."
		elog "Scripts import the GI namespaces:"
		elog "    from gi.repository import Gwyddion, GwyApp, GwyUI"
		elog "This is a breaking change from the 2.x 'import gwy' interface."
		elog ""
		elog "Plug-in directories searched (in order):"
		elog "    \$GWYDDION_PYGWY_PATH"
		elog "    \$XDG_DATA_HOME/gwyddion3/pygwy/"
		elog "    ${EPREFIX}/usr/share/gwyddion3/pygwy/"
		elog ""
		elog "A Python console is registered under menu /Python Console."
		elog "Set GWYDDION_PYGWY_RELOAD=1 to hot-reload plug-ins on mtime change."
	fi
}
