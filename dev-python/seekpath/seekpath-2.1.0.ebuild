# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

#PYTHON_COMPAT=( python3_{11..13} )
PYTHON_COMPAT=( python3_11 )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Obtain and visualize k-vector coefficients and obtain band paths"
HOMEPAGE="https://seekpath.readthedocs.io/en/latest/"

DEPEND="${PYTHON_DEPS}

		sci-libs/spglib
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
	
"
#[${PYTHON_USEDEP}]

BDEPEND="${DEPEND}"
RDEPEND="${DEPEND}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test mirror"

##multiple setuptools warnings!
