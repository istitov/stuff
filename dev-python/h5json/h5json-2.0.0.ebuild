# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="JSON representation of HDF5 files, and the h5tojson/jsontoh5 tools"
HOMEPAGE="
	https://github.com/HDFGroup/hdf5-json
	https://support.hdfgroup.org/documentation/hdf5-json/latest/
	https://pypi.org/project/h5json/
"

# This uses HDF Group's five-clause h5serv license, not the NCSA-HDF license
# covering the C library; no existing tree license matched its text.
# verified 2026-09-03
LICENSE="h5serv"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/h5py-3.10[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.0[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-4.4.0[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
"

# The PyPI sdist omits tests.
distutils_enable_tests import-check
