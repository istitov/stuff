# Copyright 2004-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
inherit python-single-r1 xdg cmake

DESCRIPTION="postscript font editor and converter"
HOMEPAGE="https://fontforge.org/"
SRC_URI="https://github.com/fontforge/fontforge/releases/download/${PV}/${P}.tar.xz"

LICENSE="BSD GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc truetype-debugger gif gtk harfbuzz jpeg png +python readline test tiff woff2"
RESTRICT="!test? ( test )"
# HarfBuzz is only probed for the GUI's text shaping.
REQUIRED_USE="
	harfbuzz? ( gtk )
	python? ( ${PYTHON_REQUIRED_USE} )
"

RDEPEND="
	>=dev-libs/glib-2.67:2
	dev-libs/libxml2:2=
	>=media-libs/freetype-2.3.7:2=
	virtual/libiconv
	virtual/libintl
	virtual/zlib:=
	gif? ( media-libs/giflib:= )
	gtk? (
		dev-cpp/gtkmm:3.0
		>=x11-libs/gtk+-3.10:3
		harfbuzz? ( media-libs/harfbuzz:= )
	)
	jpeg? ( media-libs/libjpeg-turbo:= )
	png? ( media-libs/libpng:= )
	python? ( ${PYTHON_DEPS} )
	readline? ( sys-libs/readline:0= )
	tiff? ( media-libs/tiff:= )
	truetype-debugger? ( >=media-libs/freetype-2.3.8:2[fontforge,-bindist(-)] )
	woff2? ( media-libs/woff2:0= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
	doc? ( >=dev-python/sphinx-2 )
	python? ( ${PYTHON_DEPS} )
	test? ( ${RDEPEND} )
"

PATCHES=(
	"${FILESDIR}"/fontforge-doc-no-warn-error.patch
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	local mycmakeargs=(
		# The Sphinx HTML goes to DOCDIR; keep it apart so that
		# docompress -x can leave its images and indexes readable.
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}/html"
		-DENABLE_DOCS=$(usex doc ON OFF)
		-DENABLE_GUI=$(usex gtk ON OFF)
		-DENABLE_HARFBUZZ=$(usex harfbuzz ON OFF)
		-DENABLE_LIBGIF=$(usex gif ON OFF)
		-DENABLE_LIBJPEG=$(usex jpeg ON OFF)
		-DENABLE_LIBPNG=$(usex png ON OFF)
		-DENABLE_LIBREADLINE=$(usex readline ON OFF)
		-DENABLE_LIBSPIRO=OFF # No package in ::gentoo
		-DENABLE_LIBTIFF=$(usex tiff ON OFF)
		-DENABLE_MAINTAINER_TOOLS=OFF
		-DENABLE_PYTHON_EXTENSION=$(usex python ON OFF)
		-DENABLE_PYTHON_SCRIPTING=$(usex python ON OFF)
		-DENABLE_TILE_PATH=ON
		-DENABLE_WOFF2=$(usex woff2 ON OFF)
	)

	if use python; then
		python_setup
		mycmakeargs+=( -DPython3_EXECUTABLE="${PYTHON}" )
	fi

	if use truetype-debugger ; then
		local ft2="${ESYSROOT}/usr/include/freetype2"
		local ft2i="${ft2}/internal4fontforge"
		mycmakeargs+=(
			-DENABLE_FREETYPE_DEBUGGER="${ft2}"
			-DFreeTypeSource_INCLUDE_DIRS="${ft2};${ft2i}/include;${ft2i}/include/freetype;${ft2i}/src/truetype"
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install
	docompress -x /usr/share/doc/${PF}/html
	einstalldocs
	find "${ED}" -name '*.la' -type f -delete || die
}
