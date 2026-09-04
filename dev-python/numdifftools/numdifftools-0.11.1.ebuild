# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=pdm-backend
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Solves automatic numerical differentiation problems in one or more variables"
HOMEPAGE="
	https://github.com/pbrod/numdifftools/
	https://pypi.org/project/numdifftools/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	>=dev-python/numpy-2.0[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.7.3[${PYTHON_USEDEP}]
"

# 0.11.1's test suite imports hypothesis in five modules (test_fornberg,
# test_nd_scipy, test_nd_statsmodels, test_nd_algopy, test_numdifftools)
# and pyproject.toml's test extra declares hypothesis>=3.6, so the plugin
# has to be loaded for USE=test to run at all. The whole chain
# (hypothesis, hypothesis-gentoo, sortedcontainers) is stable on x86, so
# this costs no keyword. verified 2026-09-04
EPYTEST_PLUGINS=( hypothesis )
distutils_enable_tests pytest
