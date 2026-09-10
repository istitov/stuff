# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="HDF5 Plugins for Windows, MacOS, and Linux"
HOMEPAGE="https://github.com/silx-kit/hdf5plugin"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/h5py-3.0.0[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/py-cpuinfo[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

src_prepare() {
	# setup.py forces -O3 for Blosc1, where GCC 16 miscompiles blosclz_compress
	# on znver5. Other codecs work, and generic/no-strict-aliasing builds still
	# fail; cap only this legacy plugin at -O2.
	# verified 2026-06-26 (gcc-16.0.0, -march=znver5)
	grep -q 'extra_compile_args += \["-O3"\]' setup.py ||
		die "blosc -O3 line gone -- upstream changed setup.py, re-audit the blosclz gcc-16 miscompile workaround"
	sed -i -e 's|extra_compile_args += \["-O3"\]|extra_compile_args += ["-O2"]|' setup.py || die
	distutils-r1_src_prepare
}
