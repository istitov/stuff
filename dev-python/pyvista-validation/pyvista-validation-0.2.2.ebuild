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
# numpy is a BUILD dep too, and at a higher floor than at runtime: setup.py
# calls np.get_include() and compiles against the NumPy 2 API, while
# NPY_TARGET_VERSION keeps the result loadable on the 1.21 runtime floor.
BDEPEND="
	>=dev-python/numpy-2.0[${PYTHON_USEDEP}]
	>=dev-python/setuptools-64[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
"

# Version comes from setuptools-scm, which derives it from VCS; the sdist is
# not a checkout, so pin it explicitly or the build records 0.1.dev1.
export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	# Upstream pins --cov/--cov-fail-under=95 in pyproject addopts, but
	# epytest loads pytest with -p no:cov, so those turn into unrecognised
	# arguments and pytest exits before collecting anything.
	epytest -o addopts=
}
