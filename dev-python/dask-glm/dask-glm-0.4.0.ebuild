# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Generalized linear models with Dask"
HOMEPAGE="
	https://github.com/dask/dask-glm
	https://pypi.org/project/dask-glm/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/cloudpickle-1.0[${PYTHON_USEDEP}]
	>=dev-python/dask-2022.1.0[${PYTHON_USEDEP}]
	>=dev-python/distributed-2022.1.0[${PYTHON_USEDEP}]
	>=dev-python/multipledispatch-0.6.0[${PYTHON_USEDEP}]
	>=dev-python/numba-0.59[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.21[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.7[${PYTHON_USEDEP}]
	>=dev-python/scikit-learn-1.0[${PYTHON_USEDEP}]
	>=dev-python/sparse-0.15[${PYTHON_USEDEP}]
"
BDEPEND="dev-python/setuptools-scm[${PYTHON_USEDEP}]"

# setuptools_scm cannot derive a version from the gitless sdist.
export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"

# Test suite needs a dask cluster + the full ML matrix; upstream-tested.
RESTRICT="test"
