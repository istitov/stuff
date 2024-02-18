# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

#DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..11} )

inherit distutils-r1 pypi

DESCRIPTION="Mutable mapping tools"
HOMEPAGE="http://zict.readthedocs.io"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

BDEPEND="test? (
		dev-python/pytest-asyncio[${PYTHON_USEDEP}]
		dev-python/pytest-repeat[${PYTHON_USEDEP}]
		dev-python/pytest-timeout[${PYTHON_USEDEP}]
		dev-python/lmdb[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
