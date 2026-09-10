# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=scikit-build-core
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# GitHub and rmm/VERSION use zero-padded 26.08.00; PyPI normalizes to ${PV}.
MY_PV="26.08.00"

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

# Configure fetches rapids-cmake, Cython helpers, and CCCL through CPM. Installed
# librmm supplies rmm-config.cmake through its cmake.prefix entry point.
PROPERTIES="live"
RESTRICT="network-sandbox test"

RDEPEND="
	>=dev-python/cuda-bindings-13.0.1[${PYTHON_USEDEP}]
	<dev-python/cuda-bindings-14[${PYTHON_USEDEP}]
	~dev-python/librmm-26.8.0[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.0[${PYTHON_USEDEP}]
	<dev-python/numpy-3[${PYTHON_USEDEP}]
"
DEPEND="
	${RDEPEND}
	dev-util/nvidia-cuda-toolkit:=
"
# Cython cimports cuda-bindings .pxd headers; without the build dependency,
# symbols degrade to Python objects that fail nogil blocks. # verified 2026-08-06
BDEPEND="
	>=dev-build/cmake-4
	dev-build/ninja
	>=dev-python/cuda-bindings-13.0.1[${PYTHON_USEDEP}]
	<dev-python/cuda-bindings-14[${PYTHON_USEDEP}]
	>=dev-python/cython-3.2.2[${PYTHON_USEDEP}]
	~dev-python/librmm-26.8.0[${PYTHON_USEDEP}]
	>=dev-python/scikit-build-core-0.11.0[${PYTHON_USEDEP}]
"

python_prepare_all() {
	# Use the wrapped scikit-build-core backend directly, as in librmm/dask-cuda.
	sed -i \
		-e 's/build-backend = "rapids_build_backend.build"/build-backend = "scikit_build_core.build"/' \
		-e '/"rapids-build-backend>=0.4.0,<0.5.0",/d' \
		pyproject.toml || die

	# Silence CCCL's deprecated stream_ref header under RMM's -Werror build.
	# verified 2026-06-10
	sed -i \
		-e '/^  LANGUAGES CXX)/a add_compile_definitions(CCCL_IGNORE_DEPRECATED_STREAM_REF_HEADER)' \
		CMakeLists.txt || die

	distutils-r1_python_prepare_all
}
