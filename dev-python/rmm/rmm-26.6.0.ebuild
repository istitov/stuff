# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=scikit-build-core
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# GitHub zero-pads the calendar version in the tag (26.06.00); PyPI
# normalises it to 26.6.0 (${PV}). rmm/VERSION carries 26.06.00 for the
# scikit-build regex version provider.
MY_PV="26.06.00"

DESCRIPTION="RAPIDS Memory Manager — Python (Cython) bindings"
HOMEPAGE="
	https://github.com/rapidsai/rmm
	https://pypi.org/project/rmm/
"
SRC_URI="
	https://github.com/rapidsai/rmm/archive/refs/tags/v${MY_PV}.tar.gz
		-> rmm-${MY_PV}.gh.tar.gz
"
S="${WORKDIR}/rmm-${MY_PV}/python/rmm"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# The Cython build pulls rapids-cmake (branch-26.06) and the rapids
# cython helpers through CPM at configure time, and compiles against the
# CPM-fetched CCCL, so it is non-deterministic and needs network access.
# librmm (rmm-config.cmake) is found from the installed package via its
# cmake.prefix entry point.
PROPERTIES="live"
RESTRICT="network-sandbox test"

RDEPEND="
	>=dev-python/cuda-python-13.0.1[${PYTHON_USEDEP}]
	~dev-python/librmm-26.6.0[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.23[${PYTHON_USEDEP}]
"
DEPEND="
	${RDEPEND}
	dev-util/nvidia-cuda-toolkit:=
"
BDEPEND="
	>=dev-build/cmake-3.30.4
	dev-build/ninja
	>=dev-python/cython-3.0[${PYTHON_USEDEP}]
	~dev-python/librmm-26.6.0[${PYTHON_USEDEP}]
"

python_prepare_all() {
	# Bypass rapids_build_backend for the scikit_build_core.build it wraps
	# (same rationale as dev-python/dask-cuda and dev-python/librmm).
	sed -i \
		-e 's/build-backend = "rapids_build_backend.build"/build-backend = "scikit_build_core.build"/' \
		-e '/"rapids-build-backend>=0.4.0,<0.5.0",/d' \
		pyproject.toml || die

	# Same CCCL <cuda/stream_ref> deprecation guard as librmm: the Cython
	# modules compile against rmm's headers (which still include the
	# deprecated path) and may build -Werror against the slightly newer
	# CPM-fetched CCCL. Define the upstream escape macro globally.
	# verified 2026-06-10
	sed -i \
		-e '/^  LANGUAGES CXX)/a add_compile_definitions(CCCL_IGNORE_DEPRECATED_STREAM_REF_HEADER)' \
		CMakeLists.txt || die

	distutils-r1_python_prepare_all
}
