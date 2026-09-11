# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="Collection of CuTe-based CUDA kernels"
HOMEPAGE="
	https://github.com/Dao-AILab/quack
	https://pypi.org/project/quack-kernels/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Tests compile and execute CUDA kernels.
RESTRICT="test"

# Kernels are JIT-compiled through apache-tvm-ffi and CUTLASS DSL.
RDEPEND="
	dev-python/torch-c-dlpack-ext[${PYTHON_SINGLE_USEDEP}]
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/nvidia-cutlass-dsl-4.7[${PYTHON_USEDEP}]
		>=dev-python/apache-tvm-ffi-0.1.6[${PYTHON_USEDEP}]
		<dev-python/apache-tvm-ffi-0.2[${PYTHON_USEDEP}]
		dev-python/cuda-bindings[${PYTHON_USEDEP}]
		dev-python/einops[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		virtual/triton[${PYTHON_USEDEP}]
	')
"
