# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Fast base64 encoding/decoding for Python (libbase64 wrapper)"
HOMEPAGE="
	https://github.com/mayeut/pybase64
	https://pybase64.readthedocs.io/
	https://pypi.org/project/pybase64/
"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"

# pybase64 bundles aklomp/libbase64 source under base64/ and builds it
# via CMake during setup.py — no system libbase64 dep.
BDEPEND="
	>=dev-build/cmake-3.12
"
