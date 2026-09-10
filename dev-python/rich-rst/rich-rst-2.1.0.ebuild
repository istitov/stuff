# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="A beautiful reStructuredText renderer for the rich library"
HOMEPAGE="
	https://github.com/wasi-master/rich-rst
	https://pypi.org/project/rich-rst/
"
# PyPI omits test helpers and modules required for collection; use the GitHub
# archive so the full test suite runs.
SRC_URI="https://github.com/wasi-master/rich-rst/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/${PN}-${PV}"

# The vendored docutils subset is BSD-2/public-domain and excludes GPL code.
LICENSE="MIT BSD-2 public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	>=dev-python/rich-12.0.0[${PYTHON_USEDEP}]
	>=dev-python/pygments-2.0.0[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()

distutils_enable_tests pytest
