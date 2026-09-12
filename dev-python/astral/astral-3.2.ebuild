# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry-core
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="Calculations for the position of the sun and moon"
HOMEPAGE="
	https://github.com/sffjunkie/astral
	https://pypi.org/project/astral/
"
SRC_URI="https://github.com/sffjunkie/${PN}/archive/refs/tags/${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

BDEPEND="test? ( dev-python/freezegun[${PYTHON_USEDEP}] )"

DOCS=( AUTHORS ChangeLog.md ReadMe.md )

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	epytest -o cache_dir="${T}/pytest" src/test
}
