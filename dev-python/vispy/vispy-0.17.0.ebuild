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
# 0.17.0 moved the build off setuptools: the backend is hatchling, the version
# comes from hatch-vcs instead of setuptools-scm, and the single Cython
# extension is now driven by the hatch-cython build hook
# ([tool.hatch.build.targets.wheel.hooks.cython], which names hatch-cython in
# its own dependencies). setuptools stays a build requirement because upstream
# still lists it. # verified 2026-09-09
BDEPEND="
	>=dev-python/cython-3.0[${PYTHON_USEDEP}]
	dev-python/hatch-cython[${PYTHON_USEDEP}]
	dev-python/hatch-vcs[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.0[${PYTHON_USEDEP}]
"

# hatch-vcs derives the version from git and writes vispy/version.py; there is
# no .git in the sandbox, so pin it. hatch-vcs is a setuptools_scm wrapper and
# still reads SETUPTOOLS_SCM_PRETEND_VERSION, but only the unsuffixed form --
# the _FOR_VISPY variant that the setuptools build honoured is not consulted.
# verified 2026-09-09
export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"

# vispy's test suite needs a live OpenGL context / display (a GL app backend),
# which is unavailable in the build sandbox.
RESTRICT="test"
