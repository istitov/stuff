# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=meson-python
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Library for X-ray matter interaction cross sections (Python bindings)"
HOMEPAGE="
	https://github.com/tschoonj/xraylib
	https://pypi.org/project/xraylib/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-lang/swig
	dev-python/cython[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
"

# pyproject's Meson args build a static C library with classic/numpy bindings
# and no Fortran.
PATCHES=(
	"${FILESDIR}"/${P}-meson-install-tag-scalar.patch
)
