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
KEYWORDS="~amd64"

# The PyPI sdist contains tests but omits conftest.py and platform_utils.py,
# which are required even to collect them. # verified 2026-08-04.
RESTRICT="test"

# Importing fastsafetensors imports both torch and tqdm.  Typer is listed in
# upstream metadata but the sdist has no Typer import or entry point.
# verified 2026-08-04 against 0.2.2.
RDEPEND="
	>=sci-ml/pytorch-2.5.1[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/tqdm-4.66.3[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/pybind11-2.10[${PYTHON_USEDEP}]
	')
"

# The extension uses self-contained CUDA ABI declarations and loads libcudart,
# libcufile and libnuma at runtime.  Upstream's setup.py otherwise switches to
# a ROCm-specific, linked build solely when /opt/rocm exists; keep the generic
# CPU/CUDA build deterministic. # verified 2026-08-04 against 0.2.2.
python_compile() {
	local -x ROCM_PATH=
	distutils-r1_python_compile
}

pkg_postinst() {
	optfeature "CUDA and GPUDirect Storage support" dev-util/nvidia-cuda-toolkit
	optfeature "NUMA affinity" sys-process/numactl
}
