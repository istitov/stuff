# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="Loss functions, samplers, and trainers for metric learning in PyTorch"
HOMEPAGE="
	https://github.com/KevinMusgrave/pytorch-metric-learning
	https://pypi.org/project/pytorch-metric-learning/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# scipy is absent from setup.py but imported at module load. Verified 2026-05-16.
RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/scikit-learn[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
	')
"

# Tests require faiss and tensorboard fixtures.
RESTRICT="test"
