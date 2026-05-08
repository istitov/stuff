# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="High-performance safetensors model loader (GPUDirect Storage)"
HOMEPAGE="
	https://github.com/foundation-model-stack/fastsafetensors
	https://pypi.org/project/fastsafetensors/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# The C++ extension links against stdc++ only and dlopens libcufile.so /
# libcudart.so at runtime via cuda_compat.h's self-contained shim, so
# no CUDA headers are needed at build time. nvidia-cuda-toolkit is
# only required to actually use the GDS path; the CPU fallback works
# without it. Leaving it out of RDEPEND — vllm's CUDA target pulls
# the toolkit elsewhere. # verified 2026-05-07 against 0.2.2.
RDEPEND="
	>=dev-python/typer-0.9.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-python/pybind11-2.10[${PYTHON_USEDEP}]
"
