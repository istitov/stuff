# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=meson-python
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Library for azimuthal integration of 2D diffraction data"
HOMEPAGE="https://pyfai.readthedocs.io"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gui opencl"

# Upstream pyproject.toml [project].dependencies block lists numpy>=1.10,
# h5py, fabio, silx>=2, numexpr (!= 2.8.6), scipy, matplotlib unconditionally;
# pyside6 sits in the optional `gui` extra and pyopencl in `opencl`.
RDEPEND="
	dev-python/fabio[${PYTHON_USEDEP}]
	dev-python/h5py[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.10[${PYTHON_USEDEP}]
	dev-python/numexpr[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	>=dev-python/silx-2[${PYTHON_USEDEP}]
	sci-libs/fftw:3.0
	gui? ( dev-python/pyside:6[${PYTHON_USEDEP}] )
	opencl? ( dev-python/pyopencl[${PYTHON_USEDEP}] )
"

BDEPEND="
	>=dev-python/cython-0.29.31[${PYTHON_USEDEP}]
"
