# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=hatchling
inherit distutils-r1 pypi

DESCRIPTION="hdf5-based Electron Microscopy Dataset"
HOMEPAGE="https://github.com/py4dstem/emdfile"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/h5py-3.2.0[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.46.1[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
"
