# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Logging framework for RAPIDS built around fmt"
HOMEPAGE="
	https://github.com/rapidsai/rapids-logger
	https://pypi.org/project/rapids-logger/
"
SRC_URI="
	https://github.com/rapidsai/rapids-logger/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
# The installable Python package + its scikit-build CMake driver live in
# python/rapids-logger; that CMake reaches back up to the repo root to
# build the C++ logger library.
S="${WORKDIR}/${PN}-${PV}/python/rapids-logger"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The C++ build pulls rapids-cmake (branch-25.10) and fmt through
# RAPIDS's CPM wrapper at configure time, so the build is non-
# deterministic and needs network access inside the sandbox.
PROPERTIES="live"
RESTRICT="network-sandbox test"

BDEPEND="
	>=dev-build/cmake-3.30.4
	dev-build/ninja
"
