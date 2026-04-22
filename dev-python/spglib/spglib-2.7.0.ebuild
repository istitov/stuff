# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python bindings for spglib: a library for finding crystal symmetries"
HOMEPAGE="
	https://github.com/spglib/spglib
	https://pypi.org/project/spglib/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="test"

RDEPEND="
	>=dev-python/numpy-1.20[${PYTHON_USEDEP}]
	>=sci-libs/spglib-2.1.0
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-python/pybind11[${PYTHON_USEDEP}]
"
