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

# docopt, sympy and tabulate are upstream's [cli] extra, pulled
# unconditionally because this ebuild installs the pyannote-metrics
# console script (pyannote.metrics.cli:main) -- a docopt CLI that imports
# them at startup. Floors track the 4.1 [cli] extra exactly. matplotlib
# is upstream's [plot]/[doc] extra, used only by optional plotting
# helpers, so it is intentionally not pulled. verified 2026-08-17.
RDEPEND="
	>=dev-python/docopt-0.6.2[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.2.2[${PYTHON_USEDEP}]
	>=dev-python/pandas-2.2.3[${PYTHON_USEDEP}]
	>=sci-ml/pyannote-core-6.0[${PYTHON_USEDEP}]
	>=sci-ml/pyannote-database-6.0[${PYTHON_USEDEP}]
	>=dev-python/scikit-learn-1.6.1[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.15.1[${PYTHON_USEDEP}]
	>=dev-python/sympy-1.13.3[${PYTHON_USEDEP}]
	>=dev-python/tabulate-0.9.0[${PYTHON_USEDEP}]
"

RESTRICT="test"
