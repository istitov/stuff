# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Python library for simulating diffraction"
HOMEPAGE="https://github.com/pyxem/diffsims"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/numpy-1.10[${PYTHON_USEDEP}]
	>=dev-python/scipy-0.15[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.1.1[${PYTHON_USEDEP}]
	>=dev-python/tqdm-0.4.9[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	>=dev-python/diffpy-structure-3.0.0[${PYTHON_USEDEP}]
	>=dev-python/orix-0.5.0[${PYTHON_USEDEP}]
	dev-python/transforms3d[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
"
