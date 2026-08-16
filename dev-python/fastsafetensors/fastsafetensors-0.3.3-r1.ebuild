# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 optfeature pypi

DESCRIPTION="High-performance safetensors model loader"
HOMEPAGE="
	https://github.com/foundation-model-stack/fastsafetensors
	https://pypi.org/project/fastsafetensors/
"

# The sdist installs Microsoft's MIT-licensed DirectStorage headers.
LICENSE="Apache-2.0 MIT"
SLOT="0"
KEYWORDS="~amd64"

# PyTorch is the default and only packaged framework backend.  Tqdm is
# optional, while Typer is listed in upstream metadata but has no import or
# entry point. # verified 2026-08-04 against 0.3.3.
RDEPEND="
	>=sci-ml/pytorch-2.10.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/typer-0.9.0[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/pybind11-2.10[${PYTHON_USEDEP}]
		>=dev-python/setuptools-78.1.1[${PYTHON_USEDEP}]
	')
"

# The extension links only the C++ runtime.  CUDA, ROCm, GDS and NUMA support
# are discovered with dlopen at runtime, and CPU loading works without them.
# verified 2026-08-04 against 0.3.3.
pkg_postinst() {
	optfeature "progress reporting" dev-python/tqdm
	optfeature "CUDA and GPUDirect Storage support" dev-util/nvidia-cuda-toolkit
	optfeature "ROCm and hipFile support" dev-util/hip
	optfeature "NUMA affinity" sys-process/numactl
}
