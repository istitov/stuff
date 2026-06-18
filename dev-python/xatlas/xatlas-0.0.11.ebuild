# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{11..13} )

inherit distutils-r1 pypi

DESCRIPTION="Python bindings for xatlas mesh parameterization / UV unwrapping"
HOMEPAGE="
	https://github.com/mworchel/xatlas-python
	https://pypi.org/project/xatlas/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The sdist bundles both the xatlas C++ and pybind11 under extern/ (plain
# add_subdirectory, no FetchContent), so the scikit-build-core/cmake build is
# fully offline and needs no system pybind11. No runtime deps (numpy/scipy/
# trimesh are upstream test-only extras).
