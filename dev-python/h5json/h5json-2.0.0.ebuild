# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
# Upstream requires-python is >=3.11; this overlay's floor is already 3.12.
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="JSON representation of HDF5 files, and the h5tojson/jsontoh5 tools"
HOMEPAGE="
	https://github.com/HDFGroup/hdf5-json
	https://support.hdfgroup.org/documentation/hdf5-json/latest/
	https://pypi.org/project/h5json/
"

# NOT the NCSA-HDF licence ::gentoo ships for sci-libs/hdf5. That one is the
# University of Illinois / NCSA text covering the HDF5 C library; this is The
# HDF Group's own "h5serv" licence (Copyright 2014-2017), a five-clause
# BSD-style permissive licence with an acknowledgement request in clause 4.
# Different copyright holder, different text, so it gets its own file rather
# than being labelled NCSA-HDF. verified 2026-09-03 against the 2.0.0 sdist's
# COPYING, which no licence in ::gentoo or ::stuff matches byte-for-byte.
LICENSE="h5serv"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/h5py-3.10[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.0[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-4.4.0[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
"

# PyPI's source distribution does not contain the upstream test suite.
distutils_enable_tests import-check
