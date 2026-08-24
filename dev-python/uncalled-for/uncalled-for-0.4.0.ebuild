# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Async dependency injection for Python functions"
HOMEPAGE="https://pypi.org/project/uncalled-for/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="
	dev-python/hatch-vcs[${PYTHON_USEDEP}]
"

# The suite requires multiple optional development-only pytest plugins.
RESTRICT="test"

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}
