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

# Upstream's 2.0.x PyPI sdist omits tests/conftest.py (where the
# `make_visitor` and `render_text` fixtures are defined) and the
# tests/{test_sphinx_directives,test_sphinx_roles,test_tables}.py
# files — present at the github v2.0.1 tag, missing from MANIFEST.in.
# All 763 collected tests ERROR at setup with "fixture 'make_visitor'
# not found".  Switch SRC_URI to the github archive (or wait for an
# upstream MANIFEST.in fix) before re-enabling.  # verified
# 2026-05-16 against the PyPI sdist.
RESTRICT="test"
