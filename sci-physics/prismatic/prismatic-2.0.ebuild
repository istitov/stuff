# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{9..12} )

#inherit distutils-r1 qmake-utils
inherit cmake qmake-utils

DISTUTILS_EXT=1
DESCRIPTION="Prismatic Software for STEM Simulation"
HOMEPAGE="https://prism-em.com"
SRC_URI="https://github.com/prism-em/prismatic/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python debug gui gpu"
#RESTRICT=strip

RDEPEND="
	dev-build/cmake
	dev-libs/boost
	sci-libs/fftw[threads]
	sci-libs/hdf5[cxx]
	gpu? ( dev-util/nvidia-cuda-toolkit )
"

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

src_prepare() {
	if use gui; then
		sed -i -e 's:set(PRISMATIC_ENABLE_GUI 0:set(PRISMATIC_ENABLE_GUI 1:' CMakeLists.txt || die
	fi

	if use gpu; then
		sed -i -e 's:set(PRISMATIC_ENABLE_GPU 0:set(PRISMATIC_ENABLE_GPU 1:' CMakeLists.txt || die
	fi
	cmake_src_prepare
}

#if use debug; then
#		sed -i -e 's:set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -w:set(CMAKE_CXX_FLAGS  #"${CMAKE_CXX_FLAGS} -w -DNDEBUG:' CMakeLists.txt || die
#	fi

src_configure() {
	cmake_src_configure
}

#	local mycmakeargs=''
#	if use debug; then
#		local mycmakeargs=(
#		'-DNDEBUG'
#	)
#	fi
