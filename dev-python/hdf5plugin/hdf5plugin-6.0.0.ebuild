# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="HDF5 Plugins for Windows, MacOS, and Linux"
HOMEPAGE="https://github.com/silx-kit/hdf5plugin"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/h5py-3.0.0[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/py-cpuinfo[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
