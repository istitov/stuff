# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="cuDNN Frontend Python bindings (header API + nanobind layer)"
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
# Both test suites need an NVIDIA GPU and a cuDNN backend at runtime, and
# conftest.py initializes CUDA on import. verified 2026-11-05
RESTRICT="test"

# 1.29.0 moves the CuTe DSL stack into the base requirements. The kernels
# still import it lazily, but upstream now declares it required. The other
# extras (cuda-python, cuda-tile, triton, torch, jax, and the new comm group
# carrying nvshmem4py) stay optional. verified 2026-09-23
DEPEND="
	>=dev-libs/cudnn-9
	dev-util/nvidia-cuda-toolkit:=
"
RDEPEND="${DEPEND}
	>=dev-python/apache-tvm-ffi-0.1.11[${PYTHON_USEDEP}]
	>=dev-python/nvidia-cutlass-dsl-4.8.0[${PYTHON_USEDEP}]
"
# DLPack is header-only; 1.3 declares the DLPackExchangeAPI the bindings use,
# and 1.3-r1 is the first install whose CMake config reports its version.
DEPEND+="
	>=sci-libs/dlpack-1.3-r1
"
# Root CMake and the backend require the stated floors; Ninja is optional.
# 1.32.0 moves the bindings from pybind11 to nanobind; setup.py points CMake
# at the installed nanobind on Linux instead of fetching it. The metadata
# patch uses a PEP 639 license string, which needs setuptools 77.
BDEPEND="
	>=dev-build/cmake-3.26
	>=dev-python/nanobind-3.0.1[${PYTHON_USEDEP}]
	<dev-python/nanobind-4[${PYTHON_USEDEP}]
	>=dev-python/setuptools-77[${PYTHON_USEDEP}]
"

PATCHES=(
	"${FILESDIR}"/${P}-setuptools-metadata.patch
)

src_prepare() {
	# nanobind includes Python.h after libstdc++ headers, so pyconfig.h
	# redefines _POSIX_C_SOURCE and _XOPEN_SOURCE, which upstream's -Werror
	# turns fatal. verified 2026-10-28
	sed -i -e 's/ -Werror / /' CMakeLists.txt || die

	# The Python bindings fetch DLPack from GitHub unless the system-DLPack
	# option is on, and setup.py passes no CMake arguments through, so flip
	# the option's default. verified 2026-11-05
	sed -i -e '/option(CUDNN_FRONTEND_USE_SYSTEM_DLPACK/s/ OFF)$/ ON)/' \
		python/CMakeLists.txt || die
	grep -q 'option(CUDNN_FRONTEND_USE_SYSTEM_DLPACK .* ON)$' \
		python/CMakeLists.txt || die "system-dlpack option not switched on"

	# nanobind strips release-build modules itself; leave stripping and split
	# debug info to Portage. verified 2026-11-05
	sed -i -e 's/^\(    NOMINSIZE\)$/\1\n    NOSTRIP/' python/CMakeLists.txt || die
	grep -qx '    NOSTRIP' python/CMakeLists.txt || die "NOSTRIP not added"

	distutils-r1_src_prepare
}
