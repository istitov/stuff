# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

#inherit distutils-r1 qmake-utils
inherit cmake

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

		# CUDA 13 dropped sm_60 support; bump the hard-coded
		# -arch=sm_60 in CMakeLists.txt to sm_75 only when building
		# against CUDA >= 13. CUDA 12 still accepts sm_60, so leave
		# it alone there.
		local cuda_ver=$(awk '/^#define CUDA_VERSION/ {print $3; exit}' \
			"${ESYSROOT}"/opt/cuda/include/cuda.h 2>/dev/null)
		if [[ -n ${cuda_ver} && ${cuda_ver} -ge 13000 ]]; then
			sed -i -e 's/-arch=sm_60 /-arch=sm_75 /' \
				CMakeLists.txt || die
		fi
	fi
	cmake_src_prepare
}

#if use debug; then
#		sed -i -e 's:set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -w:set(CMAKE_CXX_FLAGS
#		#"${CMAKE_CXX_FLAGS} -w -DNDEBUG:' CMakeLists.txt || die
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
