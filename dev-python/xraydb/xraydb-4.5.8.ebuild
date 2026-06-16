# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="X-ray Reference Data for the Elements using SQLite"
HOMEPAGE="https://github.com/xraypy/XrayDB"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	>=dev-python/numpy-1.19[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.6[${PYTHON_USEDEP}]
	>=dev-python/sqlalchemy-2.0.1[${PYTHON_USEDEP}]
	dev-python/platformdirs[${PYTHON_USEDEP}]
"
