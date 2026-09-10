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

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The sdist omits test helpers required during collection. verified 2026-08-04
RESTRICT="test"

# torch and tqdm are imported; retain metadata-required Typer despite no code
# use. verified 2026-08-04
RDEPEND="
	>=sci-ml/pytorch-2.5.1[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/tqdm-4.66.3[${PYTHON_USEDEP}]
		>=dev-python/typer-0.9.0[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/pybind11-2.10[${PYTHON_USEDEP}]
	')
"

# Keep the generic build deterministic: setup.py switches to ROCm merely when
# /opt/rocm exists; CUDA/GDS/NUMA libraries are loaded at runtime.
# verified 2026-08-04
python_compile() {
	local -x ROCM_PATH=
	distutils-r1_python_compile
}

pkg_postinst() {
	optfeature "CUDA and GPUDirect Storage support" dev-util/nvidia-cuda-toolkit
	optfeature "NUMA affinity" sys-process/numactl
}
