# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Diffusion models for image and audio generation in PyTorch"
HOMEPAGE="
	https://github.com/huggingface/diffusers
	https://pypi.org/project/diffusers/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Tests download models and require a large collection of optional backends.
RESTRICT="test"

# dev-python/httpx is deprecated in ::gentoo since 2026-04-01, but httpx2 is
# not a drop-in replacement and upstream requires httpx<1. verified 2026-08-23.
RDEPEND="
	>=sci-ml/huggingface_hub-1.23.0[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/huggingface_hub-2[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/filelock[${PYTHON_USEDEP}]
		<dev-python/httpx-1[${PYTHON_USEDEP}]
		dev-python/importlib-metadata[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/regex[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		>=sci-ml/safetensors-0.8.0[${PYTHON_USEDEP}]
	')
"
