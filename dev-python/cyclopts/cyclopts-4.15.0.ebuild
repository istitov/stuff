# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Intuitive, easy-to-use CLI framework based on type hints"
HOMEPAGE="
	https://github.com/BrianPugh/cyclopts
	https://pypi.org/project/cyclopts/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=dev-python/attrs-23.1.0[${PYTHON_USEDEP}]
	>=dev-python/docstring-parser-0.15[${PYTHON_USEDEP}]
	>=dev-python/rich-13.6.0[${PYTHON_USEDEP}]
	>=dev-python/rich-rst-1.3.1[${PYTHON_USEDEP}]
	<dev-python/rich-rst-3.0.0[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/hatch-vcs[${PYTHON_USEDEP}]
"

# cyclopts uses hatch-vcs to derive its version from git tags. PyPI
# sdist tarballs ship a _version.py with the version baked in, but
# hatch-vcs still re-introspects from git when the source tree looks
# like one; pretend the version explicitly to keep the sandboxed
# build off git.
export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

EPYTEST_PLUGINS=()

distutils_enable_tests pytest
