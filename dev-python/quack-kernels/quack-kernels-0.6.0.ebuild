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
# flag needed. 0.6.0 tightens the cute-DSL requirement to
# nvidia-cutlass-dsl==4.6.0; the JIT'd kernels are ABI-locked to
# that upstream version. Verified 2026-08-04 against 0.6.0.
RDEPEND="
	dev-python/torch-c-dlpack-ext[${PYTHON_SINGLE_USEDEP}]
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		~dev-python/nvidia-cutlass-dsl-4.6.0[${PYTHON_USEDEP}]
		>=dev-python/apache-tvm-ffi-0.1.6[${PYTHON_USEDEP}]
		<dev-python/apache-tvm-ffi-0.2[${PYTHON_USEDEP}]
		dev-python/cuda-bindings[${PYTHON_USEDEP}]
		dev-python/einops[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/triton-bin[${PYTHON_USEDEP}]
	')
"
