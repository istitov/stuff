# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Interactive scientific visualization in Python, built on OpenGL"
HOMEPAGE="https://vispy.org/ https://github.com/vispy/vispy"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The Cython extension uses NumPy headers, so NumPy is also a build dependency.
RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/freetype-py[${PYTHON_USEDEP}]
	dev-python/hsluv[${PYTHON_USEDEP}]
	dev-python/kiwisolver[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
# hatchling uses hatch-vcs for versioning and hatch-cython for the extension;
# upstream still declares setuptools. verified 2026-09-09
BDEPEND="
	>=dev-python/cython-3.0[${PYTHON_USEDEP}]
	dev-python/hatch-cython[${PYTHON_USEDEP}]
	dev-python/hatch-vcs[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.0[${PYTHON_USEDEP}]
"

# No Git metadata is available; hatch-vcs honors only setuptools-scm's
# unsuffixed override. verified 2026-09-09
export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"

# Tests require a live OpenGL context and display.
RESTRICT="test"
