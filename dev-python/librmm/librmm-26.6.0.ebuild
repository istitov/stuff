# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# GitHub and librmm/VERSION use zero-padded 26.06.00; PyPI normalizes to ${PV}.
MY_PV="26.06.00"

DESCRIPTION="RAPIDS Memory Manager — C++ library (librmm)"
HOMEPAGE="
	https://github.com/rapidsai/rmm
	https://pypi.org/project/librmm/
"
SRC_URI="
	https://github.com/rapidsai/rmm/archive/refs/tags/v${MY_PV}.tar.gz
		-> rmm-${MY_PV}.gh.tar.gz
"
# python/librmm's CMake driver builds the repository's cpp/ tree.
S="${WORKDIR}/rmm-${MY_PV}/python/librmm"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Configure fetches rapids-cmake, CCCL, and NVTX through CPM. Installed
# rapids-logger supplies its config through a cmake.prefix entry point.
PROPERTIES="live"
RESTRICT="network-sandbox test"

RDEPEND="
	~dev-python/rapids-logger-0.2.3[${PYTHON_USEDEP}]
"
DEPEND="
	${RDEPEND}
	dev-util/nvidia-cuda-toolkit:=
"
BDEPEND="
	>=dev-build/cmake-3.30.4
	dev-build/ninja
	~dev-python/rapids-logger-0.2.3[${PYTHON_USEDEP}]
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
