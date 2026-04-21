# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
# GitHub tarballs have no git metadata; keep setuptools-scm happy.
export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_DASK=${PV}

inherit distutils-r1

DESCRIPTION="Task scheduling and blocked algorithms for parallel processing"
HOMEPAGE="
	https://www.dask.org/
	https://github.com/dask/dask/
	https://pypi.org/project/dask/
"
SRC_URI="
	https://github.com/dask/dask/archive/${PV}.tar.gz -> ${P}.gh.tar.gz
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=dev-python/click-8.1[${PYTHON_USEDEP}]
	>=dev-python/cloudpickle-3.0.0[${PYTHON_USEDEP}]
	>=dev-python/fsspec-2021.09.0[${PYTHON_USEDEP}]
	>=dev-python/packaging-20.0[${PYTHON_USEDEP}]
	>=dev-python/partd-1.4.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.3.1[${PYTHON_USEDEP}]
	>=dev-python/toolz-0.10.0[${PYTHON_USEDEP}]
"
BDEPEND="
	>=dev-python/setuptools-scm-9.0[${PYTHON_USEDEP}]
	test? (
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/pandas[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		dev-python/pytest-rerunfailures[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( pytest-rerunfailures )
distutils_enable_tests pytest

python_test() {
	epytest -p no:flaky -m "not network"
}
