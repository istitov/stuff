# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 pypi

DESCRIPTION="Obtain and visualize k-vector coefficients and obtain band paths"
HOMEPAGE="https://seekpath.readthedocs.io/en/latest/"

DEPEND="${PYTHON_DEPS}
	dev-python/spglib[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
"
BDEPEND="${DEPEND}"
RDEPEND="${DEPEND}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test mirror"

##multiple setuptools warnings!
