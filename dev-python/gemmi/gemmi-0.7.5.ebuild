# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=scikit-build-core
inherit distutils-r1 pypi

DESCRIPTION="library for structural biology"
HOMEPAGE="https://project-gemmi.github.io/"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

RDEPEND="
	virtual/zlib
	dev-python/numpy[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
# CMakeLists.txt does find_package(nanobind 2.4.0 CONFIG REQUIRED), and
# nanobind's config-version file is SameMajorVersion, so it rejects a 3.x
# install for a 2.4.0 request and the wheel build dies at configure.
# Upstream's pyproject declares an unbounded nanobind >=2.4, which its own
# CMake then contradicts. # verified 2026-09-20
BDEPEND="
	>=dev-python/nanobind-2.4[${PYTHON_USEDEP}]
	<dev-python/nanobind-3[${PYTHON_USEDEP}]
"
