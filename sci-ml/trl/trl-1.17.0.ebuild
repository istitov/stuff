# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Train transformer language models with reinforcement learning (SFT, DPO, GRPO)"
HOMEPAGE="
	https://github.com/huggingface/trl
	https://pypi.org/project/trl/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# trl/trainer/utils.py and trl/models/utils.py import torch.distributed.tensor
# and FSDP at module level, so every trainer needs torch built with
# distributed support.
# ::gentoo's split pytorch-2.12 carries the flag on caffe2 instead.
# verified 2026-10-28
RDEPEND="
	>=sci-ml/accelerate-1.11.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/datasets-4.7.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/huggingface_hub-0.34.0[${PYTHON_SINGLE_USEDEP}]
	|| (
		>=sci-ml/pytorch-2.6.0[distributed(-),${PYTHON_SINGLE_USEDEP}]
		(
			=sci-ml/pytorch-2.12*[${PYTHON_SINGLE_USEDEP}]
			=sci-ml/caffe2-2.12*[distributed,${PYTHON_SINGLE_USEDEP}]
		)
	)
	>=sci-ml/transformers-4.56.2[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/jinja2[${PYTHON_USEDEP}]
		>=dev-python/numpy-1.26.0[${PYTHON_USEDEP}]
		>dev-python/packaging-20.0-r0[${PYTHON_USEDEP}]
		>=dev-python/pandas-2.1.1[${PYTHON_USEDEP}]
		>=dev-python/psutil-5.9.4[${PYTHON_USEDEP}]
		>=dev-python/pyarrow-21.0.0[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-6.0.1[${PYTHON_USEDEP}]
	')
"

BDEPEND="$(python_gen_cond_dep '>=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]')"
