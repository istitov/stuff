# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="h5py-compatible client for the HDF REST API (HSDS)"
HOMEPAGE="
	https://github.com/HDFGroup/h5pyd
	https://pypi.org/project/h5pyd/
"
SRC_URI="https://github.com/HDFGroup/h5pyd/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
# The test suite spins up a live HSDS server and talks to it over
# HTTP; not runnable at package build time.
RESTRICT="test"

RDEPEND="
	>=dev-python/numpy-2.0.0[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	dev-python/requests-unixsocket[${PYTHON_USEDEP}]
"
