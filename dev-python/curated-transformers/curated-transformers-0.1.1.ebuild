# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="A library providing a curated set of transformer models"
HOMEPAGE="
	https://github.com/explosion/curated-transformers
	https://pypi.org/project/curated-transformers/
"
# PyPI source-dir alias is missing for this old version (404 on the
# /packages/source/c/.../ path); pin the hash-based URL.
SRC_URI="https://files.pythonhosted.org/packages/70/06/6c12c149a7f737dacc76b4c3949dbc7ff87d622567b86996896ae4d104aa/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Pinned to 0.1.x: dev-python/spacy-curated-transformers 0.3.1
# (the version compatible with spacy 3.8.x) caps it at <0.2.0,>=0.1.0.
# 0.9.x exists on PyPI but pairs with the spacy-curated-transformers
# 2.x line, which wants thinc 9.x — incompatible with our spacy 3.8.
RDEPEND="
	${PYTHON_DEPS}
	sci-ml/pytorch[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"
