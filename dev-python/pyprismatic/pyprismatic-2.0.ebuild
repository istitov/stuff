# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1
#inherit cmake

DISTUTILS_EXT=1
DESCRIPTION="Prismatic Software for STEM Simulation"
HOMEPAGE="https://prism-em.com"
SRC_URI="https://github.com/prism-em/prismatic/archive/refs/tags/v2.0.tar.gz -> ${P}.tar.gz"

MYPN="prismatic"
MYP="${MYPN}-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python debug gpu"
#RESTRICT=strip

S="${WORKDIR}/${MYP}"
BUILD_DIR=${S}

RDEPEND="
	dev-build/cmake
	dev-libs/boost
	sci-libs/fftw[threads]
	sci-libs/hdf5[cxx]
"
#FFTW (compiled with --enable-float, --enable-shared, and --enable-threads)
#HDF5 (if self-compiling, compile with --enable-cxx)	

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

python_configure_all() {
	if use gpu; then
	        DISTUTILS_ARGS=( --enable-gpu )
	fi
}
