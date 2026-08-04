# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 optfeature

DESCRIPTION="NumPy-aware dynamic Python compiler using LLVM"
HOMEPAGE="https://numba.pydata.org/
	https://github.com/numba/numba"
SRC_URI="https://github.com/numba/numba/archive/${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="0BSD BSD BSD-2 HPND MIT NVIDIA-CUDA PSF-2 PYTHON"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE+=" openmp threads"
RESTRICT="bindist mirror"

# setup.py imports NumPy to obtain headers, and requires NumPy >=2.0.0rc1
# while retaining compatibility with NumPy >=1.22 at runtime.
DEPEND+="
	>=dev-python/numpy-2.0.0[${PYTHON_USEDEP}]
	<dev-python/numpy-2.5[${PYTHON_USEDEP}]
	threads? ( >=dev-cpp/tbb-2021.6:= )
"
RDEPEND+="
	>=dev-python/llvmlite-0.47.0[${PYTHON_USEDEP}]
	<dev-python/llvmlite-0.48[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.22[${PYTHON_USEDEP}]
	<dev-python/numpy-2.5[${PYTHON_USEDEP}]
	threads? ( >=dev-cpp/tbb-2021.6:= )
"
BDEPEND+="
	>=dev-python/numpy-2.0.0[${PYTHON_USEDEP}]
	<dev-python/numpy-2.5[${PYTHON_USEDEP}]
"

distutils_enable_tests unittest

pkg_setup() {
	if ! use openmp; then
		export NUMBA_DISABLE_OPENMP=1
	else
		unset NUMBA_DISABLE_OPENMP
	fi
	if ! use threads; then
		export NUMBA_DISABLE_TBB=1
	else
		unset NUMBA_DISABLE_TBB
		export TBBROOT="${EPREFIX}/usr"
	fi
}

python_test() {
	cd "${BUILD_DIR}/install$(python_get_sitedir)" || die
	"${EPYTHON}" -m numba.runtests -v \
		numba.tests.test_import \
		numba.tests.test_llvm_version_check \
		numba.tests.test_usecases || die "tests failed for ${EPYTHON}"
}

pkg_postinst() {
	optfeature "compile CUDA code" dev-util/nvidia-cuda-toolkit
}
