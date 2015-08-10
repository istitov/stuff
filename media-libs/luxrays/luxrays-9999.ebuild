# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
PYTHON_COMPAT=( python3_4 )

inherit cmake-utils flag-o-matic mercurial python-single-r1

DESCRIPTION="Library to accelerate the ray intersection process by using GPUs."
HOMEPAGE="http://www.luxrender.net"
EHG_REPO_URI="http://src.luxrender.net/luxrays"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+blender debug"

DEPEND=">=dev-libs/boost-1.43
	media-libs/freeimage
	media-gfx/embree
	virtual/opencl
	virtual/opengl"

src_prepare() {
	python-single-r1_pkg_setup
}

src_configure() {
	append-flags "-fPIC -msse -msse2 -DLUX_USE_SSE"
	use debug && append-flags -ggdb
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}( -Wno-dev )"

	mycmakeargs="${mycmakeargs}
		  -DLUX_DOCUMENTATION=OFF
		  -DLUXRAYS_DISABLE_OPENCL=OFF
		  -DCMAKE_INSTALL_PREFIX=/usr"
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_make
}

src_install() {
	dodoc "${S}/AUTHORS.txt"
	dobin "${BUILD_DIR}/bin/slg4"
	insinto /usr/include
	doins -r "${S}/include/luxcore"
	doins -r "${S}/include/luxrays"
	doins -r "${S}/include/slg"

	dolib "${BUILD_DIR}/lib/pyluxcore.so"
	dolib.a "${BUILD_DIR}/lib/libluxcore.a"
	dolib.a "${BUILD_DIR}/lib/libluxrays.a"
	dolib.a "${BUILD_DIR}/lib/libsmallluxgpu.a"

	if use blender; then
		if VER="/usr/share/blender/*";then
		    exeinto ${VER}/scripts/addons/luxrender/
		    doexe "${CMAKE_BUILD_DIR}"/lib/*.so || die "Couldn't install Pylux"
		fi
	fi
}
