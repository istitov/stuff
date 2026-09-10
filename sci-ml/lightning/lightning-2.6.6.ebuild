# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="The deep learning framework to pretrain and finetune AI models"
HOMEPAGE="
	https://lightning.ai/
	https://github.com/Lightning-AI/pytorch-lightning
	https://pypi.org/project/lightning/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The lightning wheel contains the lightning.* namespace. Upstream also lists
# pytorch-lightning, but that only adds the legacy pytorch_lightning and
# lightning_fabric names; overlay consumers use lightning.*.
RDEPEND="
	>=sci-ml/pytorch-2.1[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/pytorch-4[${PYTHON_SINGLE_USEDEP}]
	>sci-ml/torchmetrics-0.7.0-r0[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/torchmetrics-3[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>dev-python/pyyaml-5.4-r0[${PYTHON_USEDEP}]
		<dev-python/pyyaml-8[${PYTHON_USEDEP}]
		>=dev-python/fsspec-2022.5.0[${PYTHON_USEDEP}]
		<dev-python/fsspec-2028[${PYTHON_USEDEP}]
		dev-python/aiohttp[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		>=sci-ml/lightning-utilities-0.10.0[${PYTHON_USEDEP}]
		<sci-ml/lightning-utilities-2[${PYTHON_USEDEP}]
		>=dev-python/packaging-23.0[${PYTHON_USEDEP}]
		<dev-python/packaging-27[${PYTHON_USEDEP}]
		>=dev-python/tqdm-4.57.0[${PYTHON_USEDEP}]
		<dev-python/tqdm-6[${PYTHON_USEDEP}]
		>dev-python/typing-extensions-4.5.0-r0[${PYTHON_USEDEP}]
		<dev-python/typing-extensions-6[${PYTHON_USEDEP}]
	')
"

# Tests pull a long tail (deepspeed, hydra, jsonargparse, ...).
RESTRICT="test"

src_prepare() {
	# Select the umbrella distribution rather than pytorch-lightning.
	export PACKAGE_NAME="lightning"
	distutils-r1_src_prepare
}
