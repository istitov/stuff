# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# GitHub zero-pads the calendar version in the tag (26.06.00); PyPI
# normalises it to 26.6.0 (${PV}). librmm/VERSION carries the clean
# 26.06.00 string that scikit-build's regex version provider reads.
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
# The installable package + its scikit-build CMake driver live in
# python/librmm; that CMake reaches the repo root cpp/ tree to build the
# C++ RMM library.
S="${WORKDIR}/rmm-${MY_PV}/python/librmm"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# The C++ build pulls rapids-cmake (branch-26.06), CCCL and NVTX through
# RAPIDS's CPM wrapper at configure time, so it is non-deterministic and
# needs network access in the sandbox. rapids-logger is found from the
# installed package via its cmake.prefix entry point rather than fetched.
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
	# Bypass rapids_build_backend (CUDA-suffix munger + dependencies.yaml
	# sourcing) for the plain scikit_build_core.build it wraps — same
	# rationale as dev-python/dask-cuda. Our rapids-logger dep is
	# unsuffixed and static in [project.dependencies]. verified 2026-06-10
	sed -i \
		-e 's/build-backend = "rapids_build_backend.build"/build-backend = "scikit_build_core.build"/' \
		-e '/"rapids-build-backend>=0.4.0,<0.5.0",/d' \
		pyproject.toml || die

	# The CPM-fetched CCCL is slightly newer than rmm 26.06 targets and
	# deprecates <cuda/stream_ref> (contents moved to <cuda/stream>).
	# rmm's headers still include the old path in 10+ places and the C++
	# library builds with -Werror (cpp/CMakeLists.txt RMM_CXX_FLAGS, no
	# opt-out), so the deprecation #warning becomes a fatal error. Define
	# the upstream-documented escape macro globally — the header is only
	# deprecated, not removed, so this is safe. verified 2026-06-10
	sed -i \
		-e '/^  LANGUAGES CXX)/a add_compile_definitions(CCCL_IGNORE_DEPRECATED_STREAM_REF_HEADER)' \
		../../cpp/CMakeLists.txt || die

	distutils-r1_python_prepare_all
}
