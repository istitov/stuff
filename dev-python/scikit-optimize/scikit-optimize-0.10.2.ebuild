# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_PN=${PN/-/_}
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 pypi

DESCRIPTION="Sequential model-based optimization library"
HOMEPAGE="https://scikit-optimize.github.io/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

# Upstream pyproject lists `pyaml>=16.9`, but skopt's source uses
# `import yaml` (PyYAML) — the dep is mislabelled upstream, so keep
# dev-python/pyyaml here. matplotlib is upstream's `[plots]` extra
# but commonly used; kept unconditional for now.
RDEPEND="
	>=dev-python/joblib-0.11[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.20.3[${PYTHON_USEDEP}]
	>=dev-python/packaging-21.3[${PYTHON_USEDEP}]
	>=dev-python/scikit-learn-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.1.0[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
