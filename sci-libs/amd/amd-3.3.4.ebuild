# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FORTRAN_NEEDED="fortran"
inherit cmake fortran-2

Sparse_PV="7.12.2"
Sparse_P="SuiteSparse-${Sparse_PV}"
DESCRIPTION="Library to order a sparse matrix prior to Cholesky factorization"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v${Sparse_PV}.tar.gz -> ${Sparse_P}.gh.tar.gz"

S="${WORKDIR}/${Sparse_P}/${PN^^}"
LICENSE="BSD"
SLOT="0/3"
KEYWORDS="~amd64 ~x86"
IUSE="doc fortran test"
RESTRICT="!test? ( test )"

DEPEND=">=sci-libs/suitesparseconfig-${Sparse_PV}"
RDEPEND="${DEPEND}"
BDEPEND="doc? ( virtual/latex-base )"

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_STATIC_LIBS=OFF
		-DSUITESPARSE_USE_FORTRAN=$(usex fortran ON OFF)
		-DSUITESPARSE_DEMOS=$(usex test ON OFF)
		-DSUITESPARSE_USE_CUDA=OFF
		-DSUITESPARSE_USE_PYTHON=OFF
		-DBLA_VENDOR=Generic
	)
	cmake_src_configure
}

src_test() {
	cd "${BUILD_DIR}"
	local demofiles=(
		amd_demo
		amd_l_demo
		amd_demo2
		amd_simple
	)
	if use fortran; then
		demofiles+=(
			amd_f77simple
			amd_f77demo
		)
	fi
	for i in ${demofiles}; do
		./"${i}" > "${i}.out"
		diff "${S}/Demo/${i}.out" "${i}.out" || die "failed testing ${i}"
	done
	einfo "All tests passed"
}

src_install() {
	if use doc; then
		pushd "${S}/Doc"
		emake clean
		rm -rf *.pdf
		emake
		popd
		DOCS="${S}/Doc/*.pdf"
	fi
	cmake_src_install
}
