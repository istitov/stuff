# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..11} )

inherit distutils-r1 pypi

DESCRIPTION="Python library for multi-dimensional diffraction microscopy"
HOMEPAGE="https://pyxem.github.io"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python"

RDEPEND="
	dev-python/scikit-image[${PYTHON_USEDEP}]
	dev-python/scikit-learn[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/hyperspy[${PYTHON_USEDEP}]
	dev-python/lmfit[${PYTHON_USEDEP}]
	dev-python/diffsims[${PYTHON_USEDEP}]
	dev-python/pyfai[${PYTHON_USEDEP}]
	dev-python/ipywidgets[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
"
#	>=dev-python/matplotlib-3.1.1

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"
