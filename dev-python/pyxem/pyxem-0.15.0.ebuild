# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python library for multi-dimensional diffraction microscopy"
HOMEPAGE="https://pyxem.github.io"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/dask[${PYTHON_USEDEP}]
	>=dev-python/diffsims-0.5[${PYTHON_USEDEP}]
	>=dev-python/hyperspy-1.7.0[${PYTHON_USEDEP}]
	dev-python/ipywidgets[${PYTHON_USEDEP}]
	>=dev-python/lmfit-0.9.12[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.3[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/orix-0.9[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/pyfai[${PYTHON_USEDEP}]
	>=dev-python/scikit-image-0.19.0[${PYTHON_USEDEP}]
	>=dev-python/scikit-learn-1.0[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/transforms3d[${PYTHON_USEDEP}]
"
