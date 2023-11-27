# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="Linear operators to allow solving large-scale optimization problems"
HOMEPAGE="https://github.com/PyLops/pylops"

LICENSE="LGPLv3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python"

RDEPEND="
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/llvmlite[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	dev-python/pywavelets[${PYTHON_USEDEP}]
"

#	dev-python/pyFFTW[${PYTHON_USEDEP}] #have internal error with cython-3*
#    "scikit-fmm",
#    "spgl1",

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
