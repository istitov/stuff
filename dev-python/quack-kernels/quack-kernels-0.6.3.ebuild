# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

# Python 3.15 remains unkeyworded in ::gentoo (verified 2026-08-04).

inherit distutils-r1 pypi

DESCRIPTION="Collection of CuTe-based CUDA kernels"
HOMEPAGE="
	https://github.com/Dao-AILab/quack
	https://pypi.org/project/quack-kernels/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# The meaningful upstream tests compile and run CUDA kernels.
RESTRICT="test"

# Pure-Python; the kernels themselves are JIT-compiled at first use
# via apache-tvm-ffi + nvidia-cutlass-dsl. Upstream's cu13 extra
# selects the matching cutlass-dsl[cu13] sub-libs which we already
# pull via dev-python/nvidia-cutlass-dsl on this overlay; no USE
# flag needed. 0.6.3 loosened the cute-DSL requirement from
# ==4.6.1 to ~=4.6.0 (the 4.6 series, <4.7); the JIT'd kernels stay
# ABI-locked to 4.6.x, so we pin the 4.6.1 we ship and cutlass-dsl
# 4.7.0 stays out until upstream quack moves off 4.6.
# Verified 2026-08-06 against 0.6.3.
RDEPEND="
	dev-python/torch-c-dlpack-ext[${PYTHON_SINGLE_USEDEP}]
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		~dev-python/nvidia-cutlass-dsl-4.6.1[${PYTHON_USEDEP}]
		>=dev-python/apache-tvm-ffi-0.1.6[${PYTHON_USEDEP}]
		<dev-python/apache-tvm-ffi-0.2[${PYTHON_USEDEP}]
		dev-python/cuda-bindings[${PYTHON_USEDEP}]
		dev-python/einops[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		virtual/triton[${PYTHON_USEDEP}]
	')
"
