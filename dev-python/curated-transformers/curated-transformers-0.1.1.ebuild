# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

DESCRIPTION="A library providing a curated set of transformer models"
HOMEPAGE="
	https://github.com/explosion/curated-transformers
	https://pypi.org/project/curated-transformers/
"
# PyPI's normalized source URL is absent for this old release.
SRC_URI="https://files.pythonhosted.org/packages/70/06/6c12c149a7f737dacc76b4c3949dbc7ff87d622567b86996896ae4d104aa/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# spacy-curated-transformers 0.3.x requires this 0.1.x line; newer releases
# pair with its 2.x line and incompatible Thinc 9.
RDEPEND="
	${PYTHON_DEPS}
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"
