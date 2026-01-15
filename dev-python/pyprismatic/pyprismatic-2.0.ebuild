# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..14} )
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
inherit distutils-r1
#inherit cmake

MYPN="prismatic"
MYP="${MYPN}-${PV}"

DESCRIPTION="Prismatic Software for STEM Simulation"
HOMEPAGE="https://prism-em.com"
SRC_URI="https://github.com/prism-em/${MYPN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${MYP}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python debug gpu"
#RESTRICT=strip
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
