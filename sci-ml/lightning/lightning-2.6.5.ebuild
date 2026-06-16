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

# The lightning wheel ships its own self-contained code under the
# lightning/ namespace (lightning.fabric, lightning.pytorch, lightning.data).
# Upstream's Requires-Dist lists pytorch-lightning as a runtime dep, but
# that's a co-installable redundancy: pytorch-lightning ships the same code
# under the legacy pytorch_lightning + lightning_fabric top-level names.
# Downstream consumers in this overlay (sci-ml/pyannote-audio) only use the
# `lightning.*` umbrella import path, so we deliberately omit it. Users
# needing `import pytorch_lightning` can pip-install it separately.
RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/torchmetrics-0.7.1[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/pyyaml-5.4[${PYTHON_USEDEP}]
		>=dev-python/fsspec-2022.5.0[${PYTHON_USEDEP}]
		dev-python/aiohttp[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		>=sci-ml/lightning-utilities-0.10.0[${PYTHON_USEDEP}]
		>=dev-python/packaging-23.0[${PYTHON_USEDEP}]
		>=dev-python/tqdm-4.57.0[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.5.0[${PYTHON_USEDEP}]
	')
"

# Tests pull a long tail (deepspeed, hydra, jsonargparse, ...).
RESTRICT="test"

src_prepare() {
	# Lightning's setup.py reads PACKAGE_NAME from env to choose between the
	# `lightning` umbrella and `pytorch-lightning` build artifacts. The sdist
	# defaults to building `lightning`, but make it explicit.
	export PACKAGE_NAME="lightning"
	distutils-r1_src_prepare
}
