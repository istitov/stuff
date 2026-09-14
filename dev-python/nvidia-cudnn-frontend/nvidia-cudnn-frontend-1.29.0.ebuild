# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="cuDNN Frontend Python bindings (header API + pybind11 layer)"
HOMEPAGE="
	https://github.com/NVIDIA/cudnn-frontend
	https://pypi.org/project/nvidia-cudnn-frontend/
"

# PyPI is wheel-only; build from the v-prefixed tag, whose archive directory
# omits that prefix.
SRC_URI="
	https://github.com/NVIDIA/cudnn-frontend/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/cudnn-frontend-${PV}"

LICENSE="Apache-2.0 MIT"
SLOT="0"
KEYWORDS="~amd64"

# Python CMake fetches its pinned DLPack 1.3, which Gentoo does not package.
# verified 2026-09-02
RESTRICT="network-sandbox"

# 1.29.0 moves the CuTe DSL stack into the base requirements. The kernels
# still import it lazily, but upstream now declares it required. The other
# extras (cuda-python, cuda-tile, triton, torch, jax) stay optional.
# verified 2026-09-14
DEPEND="
	>=dev-libs/cudnn-9
	dev-util/nvidia-cuda-toolkit:=
"
RDEPEND="${DEPEND}
	>=dev-python/apache-tvm-ffi-0.1.11[${PYTHON_USEDEP}]
	>=dev-python/nvidia-cutlass-dsl-4.6.2[${PYTHON_USEDEP}]
"
# Root CMake and the backend require the stated floors; Ninja is optional.
# The upstream pybind11 <3 cap is conservative: 3.0.4 compile-tested.
# verified 2026-09-14
BDEPEND="
	>=dev-build/cmake-3.23
	>=dev-python/pybind11-2.13[${PYTHON_USEDEP}]
	>=dev-python/setuptools-64[${PYTHON_USEDEP}]
"
