# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs

Sparse_PV=$(ver_rs 3 '.')
Sparse_P="SuiteSparse-${Sparse_PV}"
DESCRIPTION="Common configurations for all packages in suitesparse"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v${Sparse_PV}.tar.gz -> ${Sparse_P}.gh.tar.gz"

S="${WORKDIR}/${Sparse_P}/SuiteSparse_config"
LICENSE="BSD"
SLOT="0/7"
KEYWORDS="~amd64 ~x86"
IUSE="openmp"

# we need to depend on blas as the cmake file looks for it.
# It is also a runtime dependency as it has headers to link with blas
DEPEND="virtual/blas"
RDEPEND="${DEPEND}"

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_configure() {
	# The SuiteSparse 7.x option scheme; NSTATIC/NFORTRAN/NOPENMP are gone.
	# Pin BLAS to the reference implementation (virtual/blas provides
	# libblas.so.3) so CMake's BLAS detection does not pick up a stray
	# Intel MKL install from /opt.
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_STATIC_LIBS=OFF
		-DSUITESPARSE_USE_FORTRAN=OFF
		-DSUITESPARSE_USE_OPENMP=$(usex openmp ON OFF)
		-DSUITESPARSE_USE_CUDA=OFF
		-DSUITESPARSE_USE_PYTHON=OFF
		-DBLA_VENDOR=Generic
	)
	cmake_src_configure
}
