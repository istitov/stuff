# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )
PYPI_PN="pyannote.metrics"

inherit distutils-r1 pypi

DESCRIPTION="Reproducible evaluation, diagnostic, and error analysis for speaker diarization"
HOMEPAGE="
	https://pyannote.github.io/pyannote-metrics/
	https://github.com/pyannote/pyannote-metrics
	https://pypi.org/project/pyannote-metrics/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/numpy-2.2.2[${PYTHON_USEDEP}]
	>=dev-python/pandas-2.2.3[${PYTHON_USEDEP}]
	>=sci-ml/pyannote-core-6.0[${PYTHON_USEDEP}]
	>=sci-ml/pyannote-database-6.0[${PYTHON_USEDEP}]
	>=dev-python/scikit-learn-1.6.1[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.15.1[${PYTHON_USEDEP}]
"

RESTRICT="test"
