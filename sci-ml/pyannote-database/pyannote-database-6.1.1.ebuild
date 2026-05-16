# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )
PYPI_PN="pyannote.database"

inherit distutils-r1 pypi

DESCRIPTION="Reproducible experimental protocols for multimedia databases"
HOMEPAGE="
	https://github.com/pyannote/pyannote-database
	https://pypi.org/project/pyannote.database/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cli"

RDEPEND="
	>=dev-python/pandas-2.2.3[${PYTHON_USEDEP}]
	>=sci-ml/pyannote-core-6.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0.2[${PYTHON_USEDEP}]
	cli? ( >=dev-python/typer-0.15.1[${PYTHON_USEDEP}] )
"

RESTRICT="test"
