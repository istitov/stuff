# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs

Sparse_PV="7.12.2"
Sparse_P="SuiteSparse-${Sparse_PV}"
DESCRIPTION="Sparse Cholesky factorization and update/downdate library"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v${Sparse_PV}.tar.gz -> ${Sparse_P}.gh.tar.gz"

S="${WORKDIR}/${Sparse_P}/${PN^^}"

LICENSE="LGPL-2.1+ gpl? ( GPL-2+ )"
SLOT="0/5"
KEYWORDS="~amd64 ~x86"
IUSE="cuda doc +gpl openmp test"
RESTRICT="!test? ( test )"

DEPEND=">=sci-libs/suitesparseconfig-${Sparse_PV}
	>=sci-libs/amd-3.3.4
	>=sci-libs/colamd-3.3.5
	virtual/lapack
	gpl? (
		>=sci-libs/camd-3.3.5
		>=sci-libs/ccolamd-3.3.5
	)
	cuda? (
		dev-util/nvidia-cuda-toolkit
		x11-drivers/nvidia-drivers
	)"
RDEPEND="${DEPEND}"
BDEPEND="doc? ( virtual/latex-base )"

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_configure() {
	# SuiteSparse 7.x dropped the per-module NCHOLESKY/NMATRIXOPS/etc.
	# toggles; CHOLMOD_GPL controls the GPL-licensed submodules
	# (Matrix_ops, Modify, Partition, Supernodal) as a group.
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_STATIC_LIBS=OFF
		-DSUITESPARSE_USE_FORTRAN=OFF
		-DSUITESPARSE_USE_OPENMP=$(usex openmp ON OFF)
		-DSUITESPARSE_USE_CUDA=$(usex cuda ON OFF)
		-DSUITESPARSE_USE_PYTHON=OFF
		-DSUITESPARSE_DEMOS=$(usex test ON OFF)
		-DCHOLMOD_GPL=$(usex gpl ON OFF)
		-DCHOLMOD_USE_CUDA=$(usex cuda ON OFF)
		-DCHOLMOD_USE_OPENMP=$(usex openmp ON OFF)
		-DBLA_VENDOR=Generic
	)

	# SuiteSparse defaults SUITESPARSE_CUDA_ARCHITECTURES to "52;75;80",
	# but CUDA 13 dropped support for compute_52 (and anything below
	# 7.5). Drop the obsolete arch when building against CUDA >= 13.
	# Honour an explicit SUITESPARSE_CUDA_ARCHITECTURES env override
	# regardless of CUDA version.
	if use cuda; then
		if [[ -n ${SUITESPARSE_CUDA_ARCHITECTURES} ]]; then
			mycmakeargs+=(
				-DSUITESPARSE_CUDA_ARCHITECTURES="${SUITESPARSE_CUDA_ARCHITECTURES}"
			)
		else
			local cuda_ver=$(awk '/^#define CUDA_VERSION/ {print $3; exit}' \
				"${ESYSROOT}"/opt/cuda/include/cuda.h 2>/dev/null)
			if [[ -n ${cuda_ver} && ${cuda_ver} -ge 13000 ]]; then
				mycmakeargs+=( -DSUITESPARSE_CUDA_ARCHITECTURES="75;80" )
			fi
		fi
	fi

	cmake_src_configure
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

pkg_postinst() {
	if use cuda; then
		local cuda_ver=$(awk '/^#define CUDA_VERSION/ {print $3; exit}' \
			"${EROOT}"/opt/cuda/include/cuda.h 2>/dev/null)
		if [[ -n ${cuda_ver} && ${cuda_ver} -ge 13000 ]]; then
			elog
			elog "Built with SUITESPARSE_CUDA_ARCHITECTURES=\"75;80\""
			elog "(Turing + Ampere). The upstream default is \"52;75;80\","
			elog "but CUDA 13 dropped support for compute capability < 7.5"
			elog "so compute_52 was removed."
			elog
			elog "If your GPU is newer than Ampere (e.g. Hopper sm_90,"
			elog "Ada Lovelace sm_89, Blackwell sm_100) and you want native"
			elog "codegen for it, override before merge:"
			elog
			elog "    SUITESPARSE_CUDA_ARCHITECTURES=\"75;80;89;90\" \\"
			elog "        emerge -1 sci-libs/cholmod"
			elog
		fi
	fi
}
