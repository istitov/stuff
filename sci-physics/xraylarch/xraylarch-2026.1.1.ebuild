# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Software for analysis of X-ray absorption and fluorescence data"
HOMEPAGE="
	https://xraypy.github.io/xraylarch/
	https://github.com/xraypy/xraylarch/
	https://pypi.org/project/xraylarch/
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="qtgui wxgui"
# Upstream tests are largely network-driven (AMCSD, MP API, XrayDB
# remote queries) and expect the full lmfit/hyperspy/... fixtures.
RESTRICT="test"

RDEPEND="
	>=dev-python/asteval-1.0.7[${PYTHON_USEDEP}]
	dev-python/charset-normalizer[${PYTHON_USEDEP}]
	dev-python/dill[${PYTHON_USEDEP}]
	dev-python/fabio[${PYTHON_USEDEP}]
	>=dev-python/h5py-3.13[${PYTHON_USEDEP}]
	dev-python/hdf5plugin[${PYTHON_USEDEP}]
	dev-python/imageio[${PYTHON_USEDEP}]
	>=dev-python/larixite-2025.5.1[${PYTHON_USEDEP}]
	>=dev-python/lmfit-1.3.1[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.10[${PYTHON_USEDEP}]
	>=dev-python/numdifftools-0.9.41[${PYTHON_USEDEP}]
	>=dev-python/numpy-2[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	>=dev-python/pillow-8.3.2[${PYTHON_USEDEP}]
	dev-python/pip[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/pyfai[${PYTHON_USEDEP}]
	>=dev-python/pyshortcuts-1.9.5[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/scikit-image[${PYTHON_USEDEP}]
	dev-python/scikit-learn[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.15[${PYTHON_USEDEP}]
	dev-python/silx[${PYTHON_USEDEP}]
	>=dev-python/sqlalchemy-2.0[${PYTHON_USEDEP}]
	dev-python/sqlalchemy-utils[${PYTHON_USEDEP}]
	dev-python/tabulate[${PYTHON_USEDEP}]
	dev-python/termcolor[${PYTHON_USEDEP}]
	dev-python/tomli[${PYTHON_USEDEP}]
	dev-python/tomli-w[${PYTHON_USEDEP}]
	>=dev-python/uncertainties-3.2.1[${PYTHON_USEDEP}]
	>=dev-python/xraydb-4.5.7[${PYTHON_USEDEP}]
	qtgui? (
		dev-python/pyqt5[${PYTHON_USEDEP}]
		dev-python/pyqtgraph[${PYTHON_USEDEP}]
	)
	wxgui? (
		>=dev-python/wxpython-4.2.2:*[${PYTHON_USEDEP}]
		>=dev-python/wxmplot-2026.1.0[${PYTHON_USEDEP}]
		>=dev-python/wxutils-2026.1.0[${PYTHON_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
