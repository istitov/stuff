# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 pypi

DESCRIPTION="Processing and analysis of 4D-STEM data"
HOMEPAGE="https://github.com/py4dstem/py4DSTEM/"
MYPN="py4DSTEM"
MYP="${MYPN}-${PV}"
SRC_URI="$(pypi_sdist_url --no-normalize "${MYPN}" "${PV}")"
S=${WORKDIR}/${MYP}

LICENSE="GPL-v3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python"

RDEPEND="
	>=dev-python/numpy-1.19[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.5.2[${PYTHON_USEDEP}]
	>=dev-python/h5py-3.2.0[${PYTHON_USEDEP}]
	>=dev-python/hdf5plugin-3.2.0[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.2.2[${PYTHON_USEDEP}]
	dev-python/ncempy[${PYTHON_USEDEP}]
	dev-python/scikit-image[${PYTHON_USEDEP}]
	dev-python/scikit-learn[${PYTHON_USEDEP}]
	dev-python/scikit-optimize[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	dev-python/dill[${PYTHON_USEDEP}]
	net-misc/gdown[${PYTHON_USEDEP}]
	dev-python/dask[${PYTHON_USEDEP}]
	dev-python/threadpoolctl[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	dev-python/ipyparallel[${PYTHON_USEDEP}]
	dev-python/mpire[${PYTHON_USEDEP}]
	dev-python/pylops[${PYTHON_USEDEP}]
	dev-python/colorspacious[${PYTHON_USEDEP}]
	dev-python/distributed[${PYTHON_USEDEP}]
	dev-python/emdfile[${PYTHON_USEDEP}]
"

#        "cuda": ["cupy >= 10.0.0"],
#        "acom": ["pymatgen >= 2022", "mp-api == 0.24.1"],
#        "aiml": ["tensorflow == 2.4.1", "tensorflow-addons <= 0.14.0", "crystal4D"],

BDEPEND="
	dev-python/cython[${PYTHON_USEDEP}]
"

DEPEND="${BDEPEND}
	${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
