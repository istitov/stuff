# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_11 )
DISTUTILS_USE_PEP517=meson-python
inherit distutils-r1 pypi

DESCRIPTION="Calculates phonon bandstructures and inelastic neutron scattering intensities"
HOMEPAGE="https://github.com/pace-neutrons/Euphonic"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python"

#importlib-resources - not sure if needed at all
#            'brille': ['brille>=0.7.0']

RDEPEND="
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/seekpath[${PYTHON_USEDEP}]
	dev-python/Pint[${PYTHON_USEDEP}]
	dev-python/threadpoolctl[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/h5py[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
