# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Passphrase generator using the Diceware method"
HOMEPAGE="
	https://github.com/ulif/diceware
	https://diceware.readthedocs.io/
	https://pypi.org/project/diceware/
"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="
	test? (
		>=dev-python/pytest-2.8.3[${PYTHON_USEDEP}]
		dev-python/pytest-cov[${PYTHON_USEDEP}]
		dev-python/coverage[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
