# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=meson-python
inherit distutils-r1 pypi

DESCRIPTION="Calculates phonon bandstructures and inelastic neutron scattering intensities"
HOMEPAGE="https://github.com/pace-neutrons/Euphonic"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="matplotlib phonopy-reader"

RDEPEND="
	dev-python/packaging[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.24.0[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.10[${PYTHON_USEDEP}]
	>=dev-python/seekpath-2.2.1[${PYTHON_USEDEP}]
	>=sci-libs/spglib-2.1.0[python,${PYTHON_USEDEP}]
	>=dev-python/pint-0.22[${PYTHON_USEDEP}]
	>=dev-python/threadpoolctl-3.0.0[${PYTHON_USEDEP}]
	>=dev-python/toolz-0.12.1[${PYTHON_USEDEP}]
	matplotlib? ( >=dev-python/matplotlib-3.8.0[${PYTHON_USEDEP}] )
	phonopy-reader? (
		>=dev-python/h5py-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-6.0[${PYTHON_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
