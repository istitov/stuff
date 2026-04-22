# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Hatch plugin to run build scripts and bundle their artifacts"
HOMEPAGE="
	https://github.com/mkniewallner/hatch-build-scripts
	https://pypi.org/project/hatch-build-scripts/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-python/hatchling[${PYTHON_USEDEP}]
	dev-python/pathspec[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
