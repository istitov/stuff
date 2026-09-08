# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="3D plotting and mesh analysis through a streamlined Pythonic interface to VTK"
HOMEPAGE="
	https://github.com/pyvista/pyvista
	https://pypi.org/project/pyvista/
	https://docs.pyvista.org/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# vtk: 0.49 raises the range to 9.3.1 <= vtk < 9.8.0, still excluding 9.4.0
# and 9.4.1. Those two exclusions are not expressible as one atom and are
# moot anyway -- ::gentoo ships only 9.5.2, which satisfies the range.
#
# pyvista-validation is new in 0.49: upstream moved pyvista._validation into
# its own distribution and == pins it, importing it at module scope in 29
# places, so it is mandatory rather than an extra. # verified 2026-09-08
RDEPEND="
	>=sci-libs/vtk-9.3.1[python,${PYTHON_SINGLE_USEDEP}]
	<sci-libs/vtk-9.8.0[python,${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/cyclopts-4.0.0[${PYTHON_USEDEP}]
		>=dev-python/matplotlib-3.0.1[${PYTHON_USEDEP}]
		>=dev-python/numpy-1.21.0[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/pooch[${PYTHON_USEDEP}]
		~dev-python/pyvista-validation-0.2.2[${PYTHON_USEDEP}]
		>=dev-python/scooby-0.5.1[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.10[${PYTHON_USEDEP}]
	')
"

EPYTEST_PLUGINS=()

distutils_enable_tests pytest
