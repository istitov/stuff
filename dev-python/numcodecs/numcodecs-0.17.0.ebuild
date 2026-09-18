# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=meson-python
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Compression and transformation codecs for data storage and communication"
HOMEPAGE="https://github.com/zarr-developers/numcodecs"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	>=dev-python/numpy-2.0[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"

# meson-python since 0.17.0; the eclass supplies it and meson. py-cpuinfo
# is gone: meson probes SIMD itself. # verified 2026-09-18
BDEPEND="
	>=dev-python/cython-3.1[${PYTHON_USEDEP}]
	>=dev-python/meson-python-0.17[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-6.2[${PYTHON_USEDEP}]
	>=dev-python/numpy-2[${PYTHON_USEDEP}]
"
