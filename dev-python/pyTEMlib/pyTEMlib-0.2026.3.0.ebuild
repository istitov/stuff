# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Model-based quantification of transmission electron microscopy data"
HOMEPAGE="
	https://github.com/pycroscopy/pyTEMlib
	https://pycroscopy.github.io/pyTEMlib/
	https://pypi.org/project/pyTEMlib/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/ase[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	dev-python/plotly[${PYTHON_USEDEP}]
	dev-python/pandas[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	dev-python/ipympl[${PYTHON_USEDEP}]
	sci-libs/spglib[python,${PYTHON_USEDEP}]
	dev-python/simpleitk-bin[${PYTHON_USEDEP}]
	dev-python/scikit-image[${PYTHON_USEDEP}]
	dev-python/scikit-learn[${PYTHON_USEDEP}]
	>=dev-python/pyNSID-0.0.7[${PYTHON_USEDEP}]
	>=dev-python/sidpy-0.12.7[${PYTHON_USEDEP}]
	>=dev-python/SciFiReaders-0.12.4[${PYTHON_USEDEP}]
	dev-python/xraylib[${PYTHON_USEDEP}]
"

# Upstream ships no test suite in the sdist (testpaths point at tests/
# and docs/, neither of which is packaged); nothing to run here.
