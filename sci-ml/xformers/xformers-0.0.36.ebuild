# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Composable building blocks for transformer models"
HOMEPAGE="
	https://github.com/facebookresearch/xformers
	https://pypi.org/project/xformers/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Tests primarily exercise unavailable accelerator kernels.
RESTRICT="test"

# Since 0.0.36 the open-source tree compiles nothing: the attention ops
# (memory_efficient_attention and the fmha backends) moved to mslk, and
# what is left of xformers/csrc only serves Meta-internal kernels.
# verified 2026-11-14
RDEPEND="
	>=sci-ml/pytorch-2.10[${PYTHON_SINGLE_USEDEP}]
	sci-ml/mslk[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep 'dev-python/numpy[${PYTHON_USEDEP}]')
"
