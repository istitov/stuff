# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 optfeature pypi

DESCRIPTION="Loss functions, samplers, and trainers for metric learning in PyTorch"
HOMEPAGE="
	https://github.com/KevinMusgrave/pytorch-metric-learning
	https://pypi.org/project/pytorch-metric-learning/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=sci-ml/pytorch-2.14.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/numpy-2.5.3[${PYTHON_USEDEP}]
	')
"

# Tests require faiss and tensorboard fixtures.
RESTRICT="test"

pkg_postinst() {
	optfeature "clustering metrics" dev-python/scikit-learn
	optfeature "faiss-backed nearest neighbour search" sci-libs/faiss
}
