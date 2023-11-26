# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..11} )

inherit distutils-r1

DESCRIPTION="Distributed scheduler for Dask"
HOMEPAGE="https://distributed.dask.org"
SRC_URI="https://github.com/dask/distributed/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"	# pyarrow, memray no x86
RESTRICT="test"	# Test phase runs with fails

RDEPEND=">dev-python/click-8.0[${PYTHON_USEDEP}]
	>=dev-python/cloudpickle-1.5.0[${PYTHON_USEDEP}]
	>=dev-python/dask-2023.9.2[${PYTHON_USEDEP}]
	>=dev-python/jinja-2.10.3[${PYTHON_USEDEP}]
	>=dev-python/locket-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/msgpack-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/packaging-20.0[${PYTHON_USEDEP}]
	>=dev-python/psutil-5.7.2[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.3.1[${PYTHON_USEDEP}]
	>=dev-python/sortedcontainers-2.0.5[${PYTHON_USEDEP}]
	>=dev-python/tblib-1.6.0[${PYTHON_USEDEP}]
	>=dev-python/toolz-0.10.0[${PYTHON_USEDEP}]
	>=dev-python/tornado-6.0.4[${PYTHON_USEDEP}]
	>=dev-python/urllib3-1.24.3[${PYTHON_USEDEP}]
	>=dev-python/zict-3.0.0[${PYTHON_USEDEP}]
"
BDEPEND="dev-python/versioneer[${PYTHON_USEDEP}]
	test? (
		dev-python/pytest-timeout[${PYTHON_USEDEP}]
		dev-python/aiohttp[${PYTHON_USEDEP}]
		dev-python/asyncssh[${PYTHON_USEDEP}]
		dev-python/bokeh[${PYTHON_USEDEP}]
		dev-python/flaky[${PYTHON_USEDEP}]
		dev-python/h5py[${PYTHON_USEDEP}]
		dev-python/ipywidgets[${PYTHON_USEDEP}]
		dev-python/jupyter-server[${PYTHON_USEDEP}]
		dev-python/lz4[${PYTHON_USEDEP}]
		dev-python/matplotlib[${PYTHON_USEDEP}]
		dev-python/memray[${PYTHON_USEDEP}]
		dev-python/netcdf4[${PYTHON_USEDEP}]
		dev-python/numba[${PYTHON_USEDEP}]
		dev-python/pandas[${PYTHON_USEDEP}]
		dev-python/paramiko[${PYTHON_USEDEP}]
		dev-python/pyarrow[${PYTHON_USEDEP}]
		dev-python/python-snappy[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/uvloop[${PYTHON_USEDEP}]
		dev-python/zstandard[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
distutils_enable_sphinx docs/source dev-python/dask-sphinx-theme dev-python/numpydoc \
	dev-python/sphinx-click \
	dev-python/sphinx-design \
	dev-python/memray

python_prepare_all() {
	use doc && { sed -i -e "/github/s/GH\#/GH\%s\#/" docs/source/conf.py || die ; \
		sed -i "/language\ = /s/None/'en'/" docs/source/conf.py || die ; \
	}
	sed -i -e '/--cov/d' pyproject.toml || die

	distutils-r1_python_prepare_all
}

python_test() {
	epytest --runslow
}
