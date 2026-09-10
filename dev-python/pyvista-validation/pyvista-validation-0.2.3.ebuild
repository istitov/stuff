# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Validate and standardize array-like input"
HOMEPAGE="
	https://github.com/pyvista/pyvista-validation
	https://pypi.org/project/pyvista-validation/
	https://validation.pyvista.org/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# typing-extensions is upstream-gated on python_version < 3.13.
RDEPEND="
	>=dev-python/numpy-1.21.0[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/typing-extensions-4.4[${PYTHON_USEDEP}]
	' python3_12)
"
# Build against NumPy 2 while NPY_TARGET_VERSION preserves the 1.21 runtime
# floor.
BDEPEND="
	>=dev-python/numpy-2.0[${PYTHON_USEDEP}]
	>=dev-python/setuptools-64[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
"

# The sdist lacks VCS metadata and otherwise records version 0.1.dev1.
export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	# Drop upstream coverage arguments because epytest disables pytest-cov.
	# Run outside the source package so it does not shadow the built extension.
	cd tests || die
	epytest -o addopts=
}
