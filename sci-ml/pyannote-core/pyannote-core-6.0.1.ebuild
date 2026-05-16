# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )
PYPI_PN="pyannote.core"

inherit distutils-r1 pypi

DESCRIPTION="Data structures for temporal segments with attached labels"
HOMEPAGE="
	http://pyannote.github.io/pyannote-core/
	https://github.com/pyannote/pyannote-core
	https://pypi.org/project/pyannote.core/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# scipy is undeclared in upstream pyproject.toml but imported at module
# top level by utils/{distance,cluster,hierarchy}.py — verified 2026-05-16.
RDEPEND="
	>=dev-python/numpy-2.0[${PYTHON_USEDEP}]
	>=dev-python/pandas-2.2.3[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	>=dev-python/sortedcontainers-2.4.0[${PYTHON_USEDEP}]
"

# Tests rely on matplotlib + scaffolding not wired up here.
RESTRICT="test"
