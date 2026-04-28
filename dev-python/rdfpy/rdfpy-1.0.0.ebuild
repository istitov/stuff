# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Module for fast computation of 2D and 3D radial distribution functions"
HOMEPAGE="https://github.com/by256/rdfpy"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"
RDEPEND="
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
"

python_prepare_all() {
	rm -rf tests || die
	distutils-r1_python_prepare_all
}
