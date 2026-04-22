# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Reading and writing scientific file formats"
HOMEPAGE="https://hyperspy.org/rosettasciio"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+hdf5 +image +speed +tiff +zspy"

RDEPEND="
	>=dev-python/dask-2022.9.2[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.22[${PYTHON_USEDEP}]
	>=dev-python/pint-0.8[${PYTHON_USEDEP}]
	>=dev-python/python-box-6[${PYTHON_USEDEP}]
	<dev-python/python-box-8[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	hdf5? ( >=dev-python/h5py-3.7[${PYTHON_USEDEP}] )
	image? (
		>=dev-python/imageio-2.16[${PYTHON_USEDEP}]
		>=dev-python/pillow-9.0.1[${PYTHON_USEDEP}]
	)
	speed? ( >=dev-python/numba-0.56[${PYTHON_USEDEP}] )
	tiff? (
		>=dev-python/tifffile-2022.7.28[${PYTHON_USEDEP}]
	)
	zspy? (
		>=dev-python/zarr-2[${PYTHON_USEDEP}]
		<dev-python/zarr-3[${PYTHON_USEDEP}]
		dev-python/msgpack[${PYTHON_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
