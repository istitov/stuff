# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYPI_PN="sitka_spruce"
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="Explore and visualize complex scientific datasets"
HOMEPAGE="
	https://github.com/xraypy/sitka-spruce
	https://pypi.org/project/sitka-spruce/
"
S="${WORKDIR}/${PYPI_PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/wxpython-4.2.4:*[${PYTHON_USEDEP}]
	>=dev-python/wxutils-2026.1.0[${PYTHON_USEDEP}]
	>=dev-python/wxmplot-2026.2.1[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.10[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.3[${PYTHON_USEDEP}]
	>=dev-python/h5py-3.13[${PYTHON_USEDEP}]
	>=dev-python/hdf5plugin-4[${PYTHON_USEDEP}]
	>=dev-python/zarr-3.1[${PYTHON_USEDEP}]
	dev-python/fsspec[${PYTHON_USEDEP}]
	>=dev-python/asteval-1.0.9[${PYTHON_USEDEP}]
	dev-python/darkdetect[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	>=dev-python/pyshortcuts-1.9.8[${PYTHON_USEDEP}]
	dev-python/platformdirs[${PYTHON_USEDEP}]
"
BDEPEND="
	>=dev-python/setuptools-scm-6.2[${PYTHON_USEDEP}]
"

PATCHES=( "${FILESDIR}/${P}-package-discovery.patch" )
