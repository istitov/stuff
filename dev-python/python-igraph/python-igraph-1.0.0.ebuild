# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..13} )
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
KEYWORDS="~amd64 ~arm64"

# Upstream guarantees unbundled compatibility only with its exact C core;
# version 1.0.0 is bundled while ::gentoo remains on 0.10.x.
# verified 2026-09-10
RDEPEND="
	dev-python/texttable[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-build/cmake
	virtual/pkgconfig
"

EPYTEST_PLUGINS=()

distutils_enable_tests pytest
