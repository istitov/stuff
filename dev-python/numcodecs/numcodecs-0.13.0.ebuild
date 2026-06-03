# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 flag-o-matic pypi

DESCRIPTION="Compression and transformation codecs for data storage and communication"
HOMEPAGE="https://github.com/zarr-developers/numcodecs"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=dev-python/numpy-1.7[${PYTHON_USEDEP}]
"

BDEPEND="
	dev-python/cython[${PYTHON_USEDEP}]
	dev-python/py-cpuinfo[${PYTHON_USEDEP}]
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
"

src_prepare() {
	# Vendored c-blosc 1.x has `typedef _Bool bool;` in shuffle.c, which is a
	# hard error under C23 (bool is now a keyword). GCC 15 defaults to gnu23,
	# so pin the C standard down to gnu17 for the vendored sources.
	# verified 2026-06-04
	append-cflags -std=gnu17
	distutils-r1_src_prepare
}
