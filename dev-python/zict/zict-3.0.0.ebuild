# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Mutable mapping tools"
HOMEPAGE="http://zict.readthedocs.io"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="test? (
		dev-python/pytest-asyncio[${PYTHON_USEDEP}]
		dev-python/pytest-repeat[${PYTHON_USEDEP}]
		dev-python/pytest-timeout[${PYTHON_USEDEP}]
		dev-python/lmdb[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( pytest-asyncio pytest-repeat pytest-timeout )
distutils_enable_tests pytest
