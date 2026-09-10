# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Interactive scientific visualization in Python, built on OpenGL"
HOMEPAGE="https://vispy.org/ https://github.com/vispy/vispy"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The Cython extension needs NumPy headers at build time.
RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/freetype-py[${PYTHON_USEDEP}]
	dev-python/hsluv[${PYTHON_USEDEP}]
	dev-python/kiwisolver[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-python/cython-3.0[${PYTHON_USEDEP}]
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

# Pin the version without Git metadata; upstream also misspells its
# setuptools_scm configuration table.
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_VISPY="${PV}"

# Tests require a live OpenGL display.
RESTRICT="test"
