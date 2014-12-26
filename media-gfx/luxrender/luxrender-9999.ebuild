# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit cmake-utils flag-o-matic python mercurial

DESCRIPTION="A GPL unbiased renderer."
HOMEPAGE="http://www.luxrender.net"
EHG_REPO_URI="http://src.luxrender.net/lux"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="sse2 doc debug +blender"

RDEPEND=">=dev-libs/boost-1.43[python]
	media-libs/openexr
	media-libs/tiff
	media-libs/libpng
	media-libs/libjpeg-turbo
	media-libs/ilmbase
	>=media-libs/freeimage-3.15.0
	virtual/opengl"
DEPEND="${RDEPEND}
	sys-devel/bison
	sys-devel/flex
	=media-libs/luxrays-${PV}[debug?]
	doc? ( >=app-doc/doxygen-1.5.7[-nodot] )"
PDEPEND="blender? ( =media-plugins/luxblend25-${PV} )"

src_configure() {
	use sse2 && append-flags "-msse -msse2 -DLUX_USE_SSE"
	use debug && append-flags -ggdb
	
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	dodoc AUTHORS.txt || die

	# installing API(s) docs
	if use doc; then
		pushd "${S}"/doxygen > /dev/null
		doxygen doxygen.template
		dohtml html/* || die "Couldn't install API docs"
		popd > /dev/null
	fi
	
	if use blender; then
		insinto /usr/share/blender/2.73/scripts/addons/luxrender/
		doins "${CMAKE_BUILD_DIR}"/pylux.so || die "Couldn't install Pylux"
	fi
}
