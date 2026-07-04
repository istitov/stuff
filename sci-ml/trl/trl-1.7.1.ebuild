# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{11..13} )

inherit distutils-r1 pypi

DESCRIPTION="Train transformer language models with reinforcement learning (SFT, DPO, GRPO)"
HOMEPAGE="
	https://github.com/huggingface/trl
	https://pypi.org/project/trl/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=sci-ml/accelerate-1.4.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/datasets-4.7.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.56.2[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/jinja2[${PYTHON_USEDEP}]
		>=dev-python/packaging-20.0[${PYTHON_USEDEP}]
	')
"
