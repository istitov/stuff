# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/openimageio/openimageio-1.1.3.ebuild,v 1.2 2013/01/16 05:50:00 pinkbyte Exp $

EAPI="5"

PYTHON_COMPAT=( python2_7 )

inherit cmake-utils eutils multilib python-r1
vcs-snapshot

DESCRIPTION="A library for reading and writing images"
HOMEPAGE="http://sites.google.com/site/openimageio/ http://github.com/OpenImageIO"
SRC_URI="http://github.com/OpenImageIO/oiio/archive/Release-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="jpeg2k ocio opencv opengl python qt4 tbb +truetype +pugixml -nopugixml"
REQUIRED_USE="pugixml? ( !nopugixml )
					nopugixml? ( !pugixml )"

RESTRICT="test" #431412

DEPEND="dev-libs/boost[python?]
	media-libs/glew
	media-libs/ilmbase
	media-libs/libpng:0
	>=media-libs/libwebp-0.2.1
	media-libs/openexr
	media-libs/tiff:0
	sci-libs/hdf5
	sys-libs/zlib
	virtual/jpeg
	jpeg2k? ( >=media-libs/openjpeg-1.5 )
	ocio? ( >=media-libs/opencolorio-1.0.7 )
	opencv? ( >=media-libs/opencv-2.3 )
	opengl? (
		virtual/glu
		virtual/opengl
		)
	qt4? (
		dev-qt/qtcore
		dev-qt/qtgui
		dev-qt/qtopengl
		)
	tbb? ( dev-cpp/tbb )
	truetype? ( >=media-libs/freetype-2 )"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${P}/src

pkg_setup() {
	if use python; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

src_prepare() {
	if use nopugixml; then
	# remove bundled code to make it build
	# https://github.com/OpenImageIO/oiio/issues/403
	rm */pugixml* || die
	fi

	# fix man page building
	# https://github.com/OpenImageIO/oiio/issues/404
	use qt4 || sed -i -e '/list.*APPEND.*cli_tools.*iv/d' doc/CMakeLists.txt
}

src_configure() {
	local mycmakeargs=(
		-DLIB_INSTALL_DIR=/usr/$(get_libdir)
		-DBUILDSTATIC=OFF
		-DLINKSTATIC=OFF
		$(use python && echo -DPYLIB_INSTALL_DIR=$(python_get_sitedir))
		-DUSE_FIELD3D=OFF # missing in Portage
		$(cmake-utils_use_use truetype freetype)
		$(cmake-utils_use_use ocio OCIO)
		$(cmake-utils_use_use opencv)
		$(cmake-utils_use_use opengl)
		$(cmake-utils_use_use jpeg2k OPENJPEG)
		$(cmake-utils_use_use python)
		$(cmake-utils_use_use qt4 QT)
		$(cmake-utils_use_use tbb)
		)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	rm -rf "${ED}"/usr/share/doc
	dodoc ../{CHANGES,CREDITS,README*} # doc/CLA-{CORPORATE,INDIVIDUAL}
	docinto pdf
	dodoc doc/*.pdf
}
