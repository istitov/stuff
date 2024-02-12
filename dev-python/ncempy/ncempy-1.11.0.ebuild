# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 pypi

DESCRIPTION="openNCEM's Python Package"
HOMEPAGE="https://github.com/ercius/openNCEM"

LICENSE="GPL-v3 MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python"

#install_requires=['numpy', 'scipy', 'matplotlib', 'h5py>=2.9.0']
#'edstomo': ['glob2', 'genfire', 'hyperspy', 'scikit-image', 'ipyvolume']

#no edstomo yet!
#issue with setuptools .edstomo.Elam discovery

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/h5py[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
"

BDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
"

DEPEND="${BDEPEND}
	${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
