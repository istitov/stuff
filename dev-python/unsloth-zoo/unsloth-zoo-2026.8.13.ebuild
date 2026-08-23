# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )
PYPI_PN="unsloth_zoo"
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="Utilities for Unsloth model training"
HOMEPAGE="
	https://github.com/unslothai/unsloth-zoo
	https://pypi.org/project/unsloth-zoo/
"

LICENSE="LGPL-3+"
SLOT="0"
KEYWORDS="~amd64"

# Tests require model downloads and supported accelerator hardware.
RESTRICT="test"

RDEPEND="
	>=dev-python/cut-cross-entropy-25.1.1[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/accelerate-0.34.1[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/datasets-3.4.1[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/datasets-4.4[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/huggingface_hub-0.34[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/peft-0.18[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/pytorch-2.4[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/pytorch-2.13[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/torchao-0.13[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.51.3[${PYTHON_SINGLE_USEDEP}]
	<=sci-ml/transformers-5.5.0-r0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/trl-0.18.2[${PYTHON_SINGLE_USEDEP}]
	<=sci-ml/trl-0.24.0-r0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/filelock[${PYTHON_USEDEP}]
		dev-python/hf-transfer[${PYTHON_USEDEP}]
		dev-python/msgspec[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		>=dev-python/packaging-24.1[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/protobuf[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		dev-python/regex[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		>=virtual/triton-3[${PYTHON_USEDEP}]
		dev-python/tyro[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		>=dev-python/wheel-0.42[${PYTHON_USEDEP}]
		>=sci-ml/sentencepiece-0.2[${PYTHON_USEDEP}]
	')
"
