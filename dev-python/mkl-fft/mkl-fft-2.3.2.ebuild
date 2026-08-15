# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=meson-python
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="NumPy interface to oneMKL Fourier transform functions"
HOMEPAGE="https://github.com/IntelPython/mkl_fft"
SRC_URI="https://github.com/IntelPython/mkl_fft/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/mkl_fft-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/numpy-1.26.4[${PYTHON_USEDEP}]
	sci-libs/mkl
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-build/cmake-3.15
	>=dev-build/meson-1.8.3
	dev-build/ninja
	dev-python/cython[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	local testdir="${BUILD_DIR}/install$(python_get_sitedir)/mkl_fft/tests"

	cd "${T}" || die
	# The optional SciPy interface requires the unpackaged mkl-service dependency.
	epytest "${testdir}" \
		--ignore="${testdir}/third_party/scipy" \
		-k 'not scipy'

	"${BUILD_DIR}/install/usr/bin/${EPYTHON}" - <<-'PY' || die
		import numpy as np
		import mkl_fft

		rng = np.random.default_rng(42)
		values = rng.standard_normal((64, 128))
		values = values + 1j * rng.standard_normal((64, 128))
		result = mkl_fft.fftn(values)
		reference = np.fft.fftn(values)
		error = float(np.max(np.abs(result - reference)))
		print(f"mkl_fft {mkl_fft.__version__}: max absolute error {error}")
		assert np.allclose(result, reference, rtol=1e-12, atol=1e-12)
	PY
}
