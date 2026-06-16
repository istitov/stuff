# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="JIT-compiled quantization GEMM kernel library (vLLM humming backend)"
HOMEPAGE="
	https://github.com/inclusionAI/humming
	https://pypi.org/project/humming-kernels/
"
S="${WORKDIR}/humming_kernels-${PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
# Bundled tests need a CUDA device + nvcc JIT (SM75+); unrunnable in the
# build sandbox. # 2026-06-14
RESTRICT="test"

# Pure-Python wheel; the GEMM kernels ship as bundled CUDA sources
# (.cu/.cuh/.cpp) and are JIT-compiled at first use via the system nvcc.
# Upstream's install target is humming-kernels[cu13]; its
# nvidia-cuda-nvcc/nvrtc/runtime wheels are satisfied here by
# dev-util/nvidia-cuda-toolkit, which the only consumer
# (dev-python/vllm[cuda]) already pulls -- no USE flag or pip cuda wheels
# needed. cuda-only by nature: vllm imports this module only under
# `if current_platform.is_cuda():`. # added 2026-06-14
RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/triton-bin[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		sci-ml/safetensors[${PYTHON_USEDEP}]
		dev-python/jinja2[${PYTHON_USEDEP}]
		dev-python/pyelftools[${PYTHON_USEDEP}]
		dev-python/nvidia-ml-py[${PYTHON_USEDEP}]
		dev-python/cuda-bindings[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		dev-python/tabulate[${PYTHON_USEDEP}]
	')
"
