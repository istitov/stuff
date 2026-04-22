# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYPI_PN="${PN/-/.}"
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Crystal structure container and parsers for structure formats"
HOMEPAGE="https://github.com/diffpy/diffpy.structure"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/numpy-1.5.1[${PYTHON_USEDEP}]
	dev-python/diffpy-utils[${PYTHON_USEDEP}]
	sci-libs/pycifrw[${PYTHON_USEDEP}]
"

src_prepare() {
	# sdist has no git info; pin dynamic version to PV.
	sed -i -e "/^dynamic\s*=/d" \
		-e "/^\[project\]$/a version = \"${PV}\"" \
		pyproject.toml || die
	distutils-r1_src_prepare
}
