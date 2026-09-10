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

# The version-independent patch replaces the absent monorepo version helper
# with uv-dynamic-versioning; the bypass supplies ${PV}.
PATCHES=( "${FILESDIR}/${PN}-static-version.patch" )

export UV_DYNAMIC_VERSIONING_BYPASS=${PV}

# Tests require the separately published CLI and documentation tools.
RESTRICT="test"
