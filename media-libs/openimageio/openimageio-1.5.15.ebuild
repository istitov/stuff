# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/openimageio/openimageio-1.3.5.ebuild,v 1.3 2014/02/17 06:41:48 brothermechanic Exp $

EAPI=5
PYTHON_COMPAT=( python3_4 )

inherit cmake-utils eutils multilib python-single-r1 vcs-snapshot

MY_P="oiio"
MY_PV="Release-${PV}"

DESCRIPTION="A library for reading and writing images"
HOMEPAGE="https://github.com/OpenImageIO"
SRC_URI="https://github.com/OpenImageIO/${MY_P}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc64 ~x86"
IUSE="gif jpeg2k colorio opencv opengl python qt ssl tbb +truetype ffmpeg X"

RESTRICT="test" #431412

RDEPEND="dev-libs/boost[python?]
	dev-libs/pugixml:=
	media-libs/ilmbase:=
	media-libs/libpng:0=
	>=media-libs/libwebp-0.2.1:=
	media-libs/openexr:=
	media-libs/tiff:0=
	sci-libs/hdf5
	sys-libs/zlib:=
	virtual/jpeg
	ffmpeg? ( virtual/ffmpeg )
	gif? ( media-libs/giflib )
	jpeg2k? ( media-libs/openjpeg )
	colorio? ( >=media-libs/opencolorio-1.0.7:= )
	opencv? (
		>=media-libs/opencv-2.3:=
		python? ( || ( <media-libs/opencv-2.9.8 >=media-libs/opencv-2.9.8[python,${PYTHON_USEDEP}] ) )
	)
	opengl? (
		virtual/glu
		virtual/opengl
		media-libs/glew
		)
	python? ( ${PYTHON_DEPS} )
	qt? (
		dev-qt/qtcore
		dev-qt/qtgui
		dev-qt/qtopengl
		)
	ssl? ( dev-libs/openssl:0 )
	tbb? ( dev-cpp/tbb )
	truetype? ( media-libs/freetype:2= )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P}"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.3.5-openexr-2.x.patch

	# remove bundled code to make it build
	# https://github.com/OpenImageIO/oiio/issues/403
#	rm */pugixml* || die

	# fix man page building
	# https://github.com/OpenImageIO/oiio/issues/404
	use qt || sed -i -e '/list.*APPEND.*cli_tools.*iv/d' src/doc/CMakeLists.txt

#	use python && python_fix_shebang .
}

src_configure() {
	local mycmakeargs=(
		-DLIB_INSTALL_DIR="/usr/$(get_libdir)"
		-DBUILDSTATIC=OFF
		-DLINKSTATIC=OFF
		$(use python && echo -DPYLIB_INSTALL_DIR="$(python_get_sitedir)")
		-DUSE_EXTERNAL_PUGIXML=ON
		-DUSE_FIELD3D=OFF # missing in Portage
		-DOIIO_BUILD_TESTS=OFF # as they are RESTRICTed
		-DSTOP_ON_WARNING=OFF
		$(cmake-utils_use_use truetype freetype)
		$(cmake-utils_use_use colorio OCIO)
		$(cmake-utils_use_use opencv)
		$(cmake-utils_use_use opengl)
		$(cmake-utils_use_use jpeg2k OPENJPEG)
		$(cmake-utils_use_use python)
		$(cmake-utils_use_use qt QT)
		$(cmake-utils_use_use tbb)
		$(cmake-utils_use_use ssl OPENSSL)
		$(cmake-utils_use_use gif)
		$(cmake-utils_use_use ffmpeg FFMPEG)
		$(cmake-utils_use_use opengl OPENGL)
		
		)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	rm -rf "${ED}"/usr/share/doc
	dodoc {CHANGES,CREDITS,README*} # src/doc/CLA-{CORPORATE,INDIVIDUAL}
	docinto pdf
	dodoc src/doc/*.pdf
}
