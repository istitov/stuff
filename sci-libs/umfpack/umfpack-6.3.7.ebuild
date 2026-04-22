# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs

Sparse_PV="7.12.2"
Sparse_P="SuiteSparse-${Sparse_PV}"
DESCRIPTION="Unsymmetric multifrontal sparse LU factorization library"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v${Sparse_PV}.tar.gz -> ${Sparse_P}.gh.tar.gz"

S="${WORKDIR}/${Sparse_P}/${PN^^}"

LICENSE="GPL-2+"
SLOT="0/6"
KEYWORDS="~amd64 ~x86"
IUSE="doc openmp test"
RESTRICT="!test? ( test )"

DEPEND=">=sci-libs/suitesparseconfig-${Sparse_PV}
	>=sci-libs/amd-3.3.4
	>=sci-libs/cholmod-5.3.4[openmp=]
	virtual/blas"
RDEPEND="${DEPEND}"
BDEPEND="doc? ( virtual/latex-base )"

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_STATIC_LIBS=OFF
		-DSUITESPARSE_USE_FORTRAN=OFF
		-DSUITESPARSE_USE_OPENMP=$(usex openmp ON OFF)
		-DSUITESPARSE_USE_CUDA=OFF
		-DSUITESPARSE_USE_PYTHON=OFF
		-DSUITESPARSE_DEMOS=$(usex test ON OFF)
		-DBLA_VENDOR=Generic
	)
	cmake_src_configure
}

src_test() {
	cd "${BUILD_DIR}"
	./umfpack_simple || die "failed testing umfpack_simple"
}

src_install() {
	if use doc; then
		pushd "${S}/Doc" || die
		rm -rf *.pdf
		emake
		popd || die
		DOCS="${S}/Doc/*.pdf"
	fi
	cmake_src_install
}
