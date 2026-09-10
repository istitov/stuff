# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="spaCy pipelines for pre-trained BERT-family transformers"
HOMEPAGE="
	https://github.com/explosion/spacy-curated-transformers
	https://pypi.org/project/spacy-curated-transformers/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The 0.3 line matches curated-transformers 0.1, curated-tokenizers 0.0,
# spaCy 3.8, and thinc 8.3; 2.x requires spaCy 4 and thinc 9.
RDEPEND="
	${PYTHON_DEPS}
	>=dev-python/curated-transformers-0.1.0[${PYTHON_SINGLE_USEDEP}]
	<dev-python/curated-transformers-0.2[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/pytorch-1.12.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/curated-tokenizers-0.0.9[${PYTHON_USEDEP}]
		<dev-python/curated-tokenizers-0.1[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"
