# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Distributed and parallel machine learning with Dask"
HOMEPAGE="
	https://github.com/dask/dask-ml
	https://ml.dask.org/
	https://pypi.org/project/dask-ml/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/dask-glm-0.2.0[${PYTHON_USEDEP}]
	>=dev-python/dask-2025.1.0[${PYTHON_USEDEP}]
	>=dev-python/distributed-2025.1.0[${PYTHON_USEDEP}]
	>=dev-python/multipledispatch-0.4.9[${PYTHON_USEDEP}]
	>=dev-python/numba-0.51.0[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.24.0[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	>=dev-python/pandas-2.0[${PYTHON_USEDEP}]
	>=dev-python/scikit-learn-1.6.1[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
"
BDEPEND="dev-python/hatch-vcs[${PYTHON_USEDEP}]"

# hatch-vcs (setuptools_scm) cannot derive a version from the gitless sdist.
export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"

# Test suite spins up a distributed cluster and exercises the full ML
# matrix (xgboost, tensorflow); fragile out of tree, upstream-tested.
RESTRICT="test"
