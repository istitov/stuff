# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="openNCEM's Python Package"
HOMEPAGE="https://github.com/ercius/openNCEM"

LICENSE="GPL-3 MIT"
SLOT="0"
KEYWORDS="~amd64"

#install_requires=['numpy', 'scipy', 'matplotlib', 'h5py>=2.9.0']
#'edstomo': ['glob2', 'genfire', 'hyperspy', 'scikit-image', 'ipyvolume']

#no edstomo yet!
#issue with setuptools .edstomo.Elam discovery

RDEPEND="
	>=dev-python/numpy-2[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	>=dev-python/h5py-3[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
"
