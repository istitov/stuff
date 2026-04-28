# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="An implementation of chunked, compressed, N-dimensional arrays for Python"
HOMEPAGE="https://github.com/zarr-developers/zarr-python"
#SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"
SRC_URI="$(pypi_sdist_url "${PN^}" "${PV}")"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/numcodecs-0.13.0[${PYTHON_USEDEP}]
	dev-python/asciitree[${PYTHON_USEDEP}]
	dev-python/fasteners[${PYTHON_USEDEP}]
"
#asciitree==0.3.3

#fasteners==0.18
#numcodecs==0.10.2
#msgpack-python==0.5.6
#setuptools-scm==7.0.5
#numpy==1.23.3
