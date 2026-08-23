# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Composable building blocks for transformer models"
HOMEPAGE="
	https://github.com/facebookresearch/xformers
	https://pypi.org/project/xformers/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

PATCHES=( "${FILESDIR}/${P}-disable-accelerator-probe.patch" )

# The test suite primarily exercises accelerator kernels.
RESTRICT="test"

RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep 'dev-python/numpy[${PYTHON_USEDEP}]')
"
BDEPEND="
	${RDEPEND}
	dev-build/ninja
"

# Build the portable CPU extension without probing accelerator device nodes.
export CUDA_VISIBLE_DEVICES=""
export HIP_VISIBLE_DEVICES=""
export ROCR_VISIBLE_DEVICES=""
export XFORMERS_DISABLE_ACCELERATOR=1
