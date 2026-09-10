# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..13} )

inherit distutils-r1 pypi

DESCRIPTION="Python bindings for xatlas mesh parameterization / UV unwrapping"
HOMEPAGE="
	https://github.com/mworchel/xatlas-python
	https://pypi.org/project/xatlas/
"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The sdist bundles xatlas and pybind11 for an offline build; numpy, scipy, and
# trimesh are test-only.
