# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Library with helpers for the jsonlines file format"
HOMEPAGE="
	https://github.com/wbolster/jsonlines
	https://pypi.org/project/jsonlines/
"

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/wbolster/jsonlines"
else
	# tests not distributed through PyPI sdist; fetch GitHub archive
	SRC_URI="https://github.com/wbolster/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"
	KEYWORDS="~amd64 ~arm64 ~x86"
fi

LICENSE="BSD"
SLOT="0"
RESTRICT="mirror"

RDEPEND="dev-python/attrs[${PYTHON_USEDEP}]"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
