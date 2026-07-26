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
# dev-python/freetype-py, a hard RDEPEND, is ~amd64-only in ::gentoo, which caps
# this to ~amd64; upstream also ships no 32-bit x86 wheels. verified 2026-07-26
KEYWORDS="~amd64"

# The single Cython extension (vispy/visuals/text/_sdf_cpu) is compiled against
# the numpy headers, so numpy is a build dep too (DEPEND=${RDEPEND}).
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

# The sdist ships vispy/version.py + PKG-INFO, but there is no .git in the
# sandbox; pin the version so setuptools_scm is deterministic. (Upstream's
# pyproject also has a [tools.setuptools_scm] table-name typo, so its own scm
# config is silently ignored regardless.)
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_VISPY="${PV}"

# vispy's test suite needs a live OpenGL context / display (a GL app backend),
# which is unavailable in the build sandbox.
RESTRICT="test"
