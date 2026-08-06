# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

DESCRIPTION="Sentence/image embeddings, retrieval, and reranking via Transformers"
HOMEPAGE="
	https://www.SBERT.net
	https://github.com/huggingface/sentence-transformers
	https://pypi.org/project/sentence-transformers/
"
SRC_URI="https://github.com/huggingface/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Tests download models from huggingface.co at runtime; sandbox forbids
# network. No unit-only subset is split out upstream.
RESTRICT="test"

RDEPEND="
	>=sci-ml/transformers-4.41.0[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/transformers-6
	>=sci-ml/huggingface_hub-0.23.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/scikit-learn[${PYTHON_USEDEP}]
	')
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"
