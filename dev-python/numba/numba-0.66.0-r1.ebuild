# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 optfeature

DESCRIPTION="NumPy aware dynamic Python compiler using LLVM"
HOMEPAGE="https://numba.pydata.org/
	https://github.com/numba"
SRC_URI="https://github.com/numba/numba/archive/${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="openmp threads"

RDEPEND="
	>=dev-python/llvmlite-0.48.0[${PYTHON_USEDEP}]
	<dev-python/llvmlite-0.49[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.22[${PYTHON_USEDEP}]
	<dev-python/numpy-2.5[${PYTHON_USEDEP}]
	threads? ( >=dev-cpp/tbb-2019.5 )
"
# numpy is needed to build, not only to run, and at a higher floor than at
# runtime. setup.py get_ext_modules() does `import numpy` for np.get_include()
# to compile the C extensions, and sets min_numpy_build_version = 2.0.0rc1
# against min_numpy_run_version = 1.22 -- so RDEPEND above is right for running
# and wrong for building. 0.66.0 ships no pyproject.toml, so the eclass
# synthesises one and nothing pulls numpy in for the build phase.
# verified 2026-07-27
BDEPEND="
	dev-python/pip[${PYTHON_USEDEP}]
	dev-python/versioneer[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.0.0[${PYTHON_USEDEP}]
	<dev-python/numpy-2.5[${PYTHON_USEDEP}]
"

pkg_setup() {
	if ! use openmp; then
		export NUMBA_DISABLE_OPENMP=1 || die
	else
		unset NUMBA_DISABLE_OPENMP || die
	fi
	if ! use threads; then
		export NUMBA_DISABLE_TBB=1 || die
	else
		unset NUMBA_DISABLE_TBB || die
		export TBBROOT="${EPREFIX}/usr" || die
	fi
}

python_compile() {
	# FIXME: parallel python building fails. See Portage bug #614464 and
	# gentoo/sci issue #1080.
	export MAKEOPTS=-j1 || die
	distutils-r1_python_compile
}

pkg_postinst() {
	optfeature "compile cuda code" dev-util/nvidia-cuda-toolkit
}
