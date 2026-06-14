# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Load and run pretrained PyTorch image model architectures"
HOMEPAGE="
	https://github.com/chaiNNer-org/spandrel
	https://pypi.org/project/spandrel/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	sci-ml/caffe2[${PYTHON_SINGLE_USEDEP}]
	sci-ml/torchvision[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		sci-ml/safetensors[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/einops[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
	')
"
