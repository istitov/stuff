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

# Bundled tests need a CUDA device and JIT-compile kernels with nvcc.
RESTRICT="test"

# Pure Python package; its bundled CUDA sources and launcher are JIT-compiled
# at use time.  The system CUDA toolkit replaces upstream's cu12/cu13 wheel
# extras.  Humming calls g++ directly for its NVRTC helper and uses PyTorch's
# Ninja-based C++ extension loader for the launcher.
RDEPEND="
	app-alternatives/ninja
	dev-util/nvidia-cuda-toolkit:=
	>=sci-ml/pytorch-2.7[${PYTHON_SINGLE_USEDEP}]
	sci-ml/caffe2[cuda,-rocm]
	sys-devel/gcc:*[cxx]
	$(python_gen_cond_dep '
		dev-python/filelock[${PYTHON_USEDEP}]
		dev-python/triton-bin[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		sci-ml/safetensors[${PYTHON_USEDEP}]
		dev-python/jinja2[${PYTHON_USEDEP}]
		dev-python/pyelftools[${PYTHON_USEDEP}]
		dev-python/nvidia-ml-py[${PYTHON_USEDEP}]
		dev-python/cuda-bindings[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		dev-python/tabulate[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
	')
"
