# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# GitHub and librmm/VERSION use zero-padded 26.10.00; PyPI normalizes to ${PV}.
MY_PV="26.10.00"

DESCRIPTION="RAPIDS Memory Manager — C++ library (librmm)"
HOMEPAGE="https://github.com/rapidsai/rmm"
SRC_URI="
	https://github.com/rapidsai/rmm/archive/refs/tags/v${MY_PV}.tar.gz
		-> rmm-${MY_PV}.gh.tar.gz
	https://github.com/rapidsai/rapids-cmake/archive/refs/tags/v${MY_PV}.tar.gz
		-> rapids-cmake-${MY_PV}.gh.tar.gz
"
# python/librmm's CMake driver builds the repository's cpp/ tree.
S="${WORKDIR}/rmm-${MY_PV}/python/librmm"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Configure fetches CCCL and NVTX through CPM, at the commit and SHA256 the
# pinned rapids-cmake lists. Installed rapids-logger supplies its config
# through a cmake.prefix entry point.
RESTRICT="network-sandbox test"

RDEPEND="
	~dev-python/rapids-logger-0.3.0[${PYTHON_USEDEP}]
"
DEPEND="
	${RDEPEND}
	dev-util/nvidia-cuda-toolkit:=
"
BDEPEND="
	>=dev-build/cmake-4
	dev-build/ninja
	~dev-python/rapids-logger-0.3.0[${PYTHON_USEDEP}]
	>=dev-python/scikit-build-core-0.11.0[${PYTHON_USEDEP}]
"

python_prepare_all() {
	# Use the wrapped scikit-build-core backend directly; dependencies are
	# already unsuffixed and static. # verified 2026-06-10
	sed -i \
		-e 's/build-backend = "rapids_build_backend.build"/build-backend = "scikit_build_core.build"/' \
		-e '/"rapids-build-backend>=0.4.0,<0.5.0",/d' \
		pyproject.toml || die

	# RMM includes CCCL's deprecated stream_ref header under -Werror; use its
	# documented compatibility macro. # verified 2026-06-10
	sed -i \
		-e '/^  LANGUAGES CXX)/a add_compile_definitions(CCCL_IGNORE_DEPRECATED_STREAM_REF_HEADER)' \
		../../cpp/CMakeLists.txt || die

	distutils-r1_python_prepare_all
}

python_compile() {
	# rmm checks rapids-cmake out from its moving release/X.Y branch; pin the
	# matching release tag instead. # verified 2026-10-08
	local -x CMAKE_ARGS="${CMAKE_ARGS}
		-DFETCHCONTENT_SOURCE_DIR_RAPIDS-CMAKE=${WORKDIR}/rapids-cmake-${MY_PV}
	"
	distutils-r1_python_compile
}
