# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..13} )
PYPI_PN="igraph"

inherit distutils-r1 pypi

DESCRIPTION="Python interface to the igraph high-performance graph library"
HOMEPAGE="
	https://github.com/igraph/python-igraph
	https://pypi.org/project/igraph/
"
S="${WORKDIR}/${PYPI_PN}-${PV}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"

# Build the bundled igraph C core (vendor/source/igraph, shipped in full in the
# sdist) with CMake. The system dev-libs/igraph would be cleaner, but it
# hard-depends on sci-mathematics/glpk, which fails to build against this host's
# (overlay-masked) SuiteSparse -- glpk can't find amd.h. The vendored core needs
# none of that. verified 2026-06-17
RDEPEND="
	dev-python/texttable[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-build/cmake
	virtual/pkgconfig
"

EPYTEST_PLUGINS=()

distutils_enable_tests pytest
