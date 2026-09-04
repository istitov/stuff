# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Runtime utilities for inspecting Python callables"
HOMEPAGE="https://pypi.org/project/griffelib/"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="
	dev-python/pdm-backend[${PYTHON_USEDEP}]
	>=dev-python/uv-dynamic-versioning-0.7.0[${PYTHON_USEDEP}]
"

# The sdist lacks the monorepo version helper referenced by pyproject.toml, so
# the patch redirects hatchling at uv-dynamic-versioning and the bypass below
# supplies the value. Version-independent on purpose -- the older ${P}-named
# patch hardcoded the version and needed rewriting every bump.
PATCHES=( "${FILESDIR}/${PN}-static-version.patch" )

export UV_DYNAMIC_VERSIONING_BYPASS=${PV}

# The suite requires the separately published CLI and documentation tools.
RESTRICT="test"
