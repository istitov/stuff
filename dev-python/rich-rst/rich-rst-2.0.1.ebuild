# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="A beautiful reStructuredText renderer for the rich library"
HOMEPAGE="
	https://github.com/wasi-master/rich-rst
	https://pypi.org/project/rich-rst/
"

# Bundled docutils subset (BSD-2 + public-domain) in rich_rst/_vendor/;
# upstream vendored to remove GPL code from the dep tree.  See
# rich_rst/_vendor/LICENSES.txt + VENDORED.md for the full rationale.
LICENSE="MIT BSD-2 public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=dev-python/rich-12.0.0[${PYTHON_USEDEP}]
	>=dev-python/pygments-2.0.0[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()

distutils_enable_tests pytest
