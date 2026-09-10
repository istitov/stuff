# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="A curated set of pretrained tokenizers"
HOMEPAGE="
	https://github.com/explosion/curated-tokenizers
	https://pypi.org/project/curated-tokenizers/
"
# This old release lacks a PyPI source alias; use a hash-pinned URL.
SRC_URI="https://files.pythonhosted.org/packages/fc/fa/b2d55f0d53c7c7f5dc0b6dbb48cc4344ee84fb572f23de28040bf2cde89d/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The 0.0 line matches spacy-curated-transformers 0.3; 0.9 belongs to its
# unrelated 2.x branch.
RDEPEND="
	${PYTHON_DEPS}
	>=dev-python/regex-2022.0.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/cython[${PYTHON_USEDEP}]
"
