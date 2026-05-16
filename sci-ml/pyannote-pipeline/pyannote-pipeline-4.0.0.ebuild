# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )
PYPI_PN="pyannote.pipeline"

inherit distutils-r1 pypi

DESCRIPTION="Tunable pipelines for hyperparameter optimization (atop optuna)"
HOMEPAGE="
	https://github.com/pyannote/pyannote-pipeline
	https://pypi.org/project/pyannote.pipeline/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# scipy is undeclared in upstream pyproject.toml but imported at module
# top level by optimizer.py (scipy.stats.bayes_mvs); optimizer.py is loaded
# via the package __init__ — verified 2026-05-16.
RDEPEND="
	>=dev-python/filelock-3.17.0[${PYTHON_USEDEP}]
	>=dev-python/optuna-4.2.0[${PYTHON_USEDEP}]
	>=sci-ml/pyannote-core-6.0[${PYTHON_USEDEP}]
	>=sci-ml/pyannote-database-6.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0.2[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.67.1[${PYTHON_USEDEP}]
"

RESTRICT="test"
