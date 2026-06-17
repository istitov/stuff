# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{11..13} )

inherit distutils-r1 pypi

DESCRIPTION="Python (nanobind) bindings to MeshFix: repair triangular meshes"
HOMEPAGE="
	https://github.com/pyvista/pymeshfix
	https://pypi.org/project/pymeshfix/
"

# The wrapper is permissive but the bundled MeshFix C++ (src/) is GPL-3.
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
"
# CMakeLists uses find_package(nanobind CONFIG REQUIRED) against the system
# install; the MeshFix C++ ships bundled under src/, so the build is offline.
BDEPEND="
	dev-python/nanobind[${PYTHON_USEDEP}]
"
