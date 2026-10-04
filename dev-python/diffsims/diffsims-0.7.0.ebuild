# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Python library for simulating diffraction"
HOMEPAGE="https://github.com/pyxem/diffsims"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/numpy-1.17.3[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.8[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.3[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.9[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	>=dev-python/diffpy-structure-3.0.2[${PYTHON_USEDEP}]
	>=dev-python/orix-0.12.1[${PYTHON_USEDEP}]
	dev-python/transforms3d[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
# matplotlib 3.11 rejects the list labels the 1D plot helpers pass, and
# orix 0.15 counts unique equivalents differently in the deprecated
# get_equivalent_hkl; neither is fixed upstream yet. verified 2026-10-05
EPYTEST_DESELECT=(
	diffsims/tests/crystallography/test_get_hkl.py::TestGetHKL::test_get_equivalent_hkl
	diffsims/tests/sims/test_diffraction_simulation.py::test_plot_profile_simulation
	diffsims/tests/simulations/test_simulations1d.py::TestSingleSimulation::test_plot
)
distutils_enable_tests pytest
