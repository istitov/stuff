# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYPI_PN="${PN/-/.}"
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 pypi

DESCRIPTION="General-purpose utilities for the diffpy libraries"
HOMEPAGE="
	https://github.com/diffpy/diffpy.utils
	https://pypi.org/project/diffpy.utils/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/xraydb[${PYTHON_USEDEP}]
"

src_prepare() {
	# sdist has no git info; pin dynamic version to PV.
	sed -i -e "/^dynamic\s*=/d" \
		-e "/^\[project\]$/a version = \"${PV}\"" \
		pyproject.toml || die
	distutils-r1_src_prepare
}
