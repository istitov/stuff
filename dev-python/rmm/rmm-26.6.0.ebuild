# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=scikit-build-core
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# Git tags and rmm/VERSION zero-pad the calendar version; PyPI uses ${PV}.
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

# CPM fetches rapids-cmake, Cython helpers, and CCCL; installed librmm provides
# rmm-config.cmake. The build therefore needs network access.
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
	# Use the wrapped scikit-build-core backend directly.
	sed -i \
		-e 's/build-backend = "rapids_build_backend.build"/build-backend = "scikit_build_core.build"/' \
		-e '/"rapids-build-backend>=0.4.0,<0.5.0",/d' \
		pyproject.toml || die

	# RMM headers use deprecated cuda/stream_ref; tolerate it against the newer
	# fetched CCCL under -Werror.
	# verified 2026-06-10
	sed -i \
		-e '/^  LANGUAGES CXX)/a add_compile_definitions(CCCL_IGNORE_DEPRECATED_STREAM_REF_HEADER)' \
		CMakeLists.txt || die

	distutils-r1_python_prepare_all
}
