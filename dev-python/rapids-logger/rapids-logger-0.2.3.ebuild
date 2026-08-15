# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

RAPIDS_CMAKE_PV="25.10.00"
CPM_PV="0.40.2"
SPDLOG_PV="1.14.1"

DESCRIPTION="Logging framework for RAPIDS built around fmt"
HOMEPAGE="
	https://github.com/rapidsai/rapids-logger
	https://pypi.org/project/rapids-logger/
"
SRC_URI="
	https://github.com/rapidsai/rapids-logger/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
	https://github.com/rapidsai/rapids-cmake/archive/refs/tags/v${RAPIDS_CMAKE_PV}.tar.gz
		-> rapids-cmake-${RAPIDS_CMAKE_PV}.gh.tar.gz
	https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_PV}/CPM.cmake
		-> CPM.cmake-${CPM_PV}
	https://github.com/gabime/spdlog/archive/refs/tags/v${SPDLOG_PV}.tar.gz
		-> spdlog-${SPDLOG_PV}.gh.tar.gz
"
# The installable Python package + its scikit-build CMake driver live in
# python/rapids-logger; that CMake reaches back up to the repo root to
# build the C++ logger library.
S="${WORKDIR}/${PN}-${PV}/python/rapids-logger"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Upstream's CPM setup normally fetches rapids-cmake and spdlog while
# configuring. Their exact release sources are provided in SRC_URI and routed
# through FetchContent's source overrides so the build stays offline.
RESTRICT="test"

BDEPEND="
	>=dev-build/cmake-3.30.4
	dev-build/ninja
"

python_compile() {
	local -x CMAKE_ARGS="
		-DFETCHCONTENT_SOURCE_DIR_RAPIDS-CMAKE=${WORKDIR}/rapids-cmake-${RAPIDS_CMAKE_PV}
		-DFETCHCONTENT_SOURCE_DIR_SPDLOG=${WORKDIR}/spdlog-${SPDLOG_PV}
		-DCPM_DOWNLOAD_LOCATION=${DISTDIR}/CPM.cmake-${CPM_PV}
	"
	distutils-r1_python_compile
}
