# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="CIF + crystal-structure helpers used by xraylarch"
HOMEPAGE="
	https://github.com/xraypy/larixite/
	https://pypi.org/project/larixite/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
# Upstream's test suite needs an internet connection to AMCSD / the
# Materials Project API; not runnable at package build time.
RESTRICT="test"

RDEPEND="
	dev-python/xraydb[${PYTHON_USEDEP}]
	>=dev-python/sqlalchemy-2[${PYTHON_USEDEP}]
	dev-python/pymatgen[${PYTHON_USEDEP}]
	>=dev-python/mp-api-0.45.8[${PYTHON_USEDEP}]
	>=dev-python/emmet-core-0.84.9[${PYTHON_USEDEP}]
"
