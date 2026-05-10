# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="3D plotting and mesh analysis through a streamlined Pythonic interface to VTK"
HOMEPAGE="
	https://github.com/pyvista/pyvista
	https://pypi.org/project/pyvista/
	https://docs.pyvista.org/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# vtk: pyvista 0.47 wants 9.2.2 <= vtk < 9.7.0 with !=9.4.0/9.4.1.
# ::gentoo currently ships sci-libs/vtk-9.4.2-r2 and 9.5.2; both are
# acceptable per the cap.
RDEPEND="
	>=dev-python/cyclopts-4.0.0[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.0.1[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.21.0[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/pooch[${PYTHON_USEDEP}]
	>=dev-python/scooby-0.5.1[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.10[${PYTHON_USEDEP}]
	>=sci-libs/vtk-9.2.2[python,${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()

distutils_enable_tests pytest
