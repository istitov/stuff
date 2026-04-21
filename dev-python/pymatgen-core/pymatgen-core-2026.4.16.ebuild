# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

MY_PN="pymatgen_core"
DESCRIPTION="Core pieces of the Python Materials Genomics library (pymatgen)"
HOMEPAGE="
	https://github.com/materialsproject/pymatgen/
	https://pypi.org/project/pymatgen-core/
"
SRC_URI="$(pypi_sdist_url --no-normalize "${MY_PN}" "${PV}")"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"	# plotly is amd64-only in ::gentoo
# Upstream test suite expects its own large test-data tree; skip.
RESTRICT="test"

RDEPEND="
	>=dev-python/matplotlib-3.8[${PYTHON_USEDEP}]
	>=dev-python/monty-2026.2.18[${PYTHON_USEDEP}]
	>=dev-python/networkx-2.7[${PYTHON_USEDEP}]
	<dev-python/numpy-3[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.25[${PYTHON_USEDEP}]
	>=dev-python/orjson-3.10[${PYTHON_USEDEP}]
	<dev-python/orjson-4[${PYTHON_USEDEP}]
	>=dev-python/palettable-3.3.3[${PYTHON_USEDEP}]
	>=dev-python/pandas-2[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.13[${PYTHON_USEDEP}]
	>=sci-libs/spglib-2.5[python,${PYTHON_USEDEP}]
	>=dev-python/sympy-1.3[${PYTHON_USEDEP}]
	>=dev-python/uncertainties-3.1[${PYTHON_USEDEP}]
	>=dev-python/plotly-6.0[${PYTHON_USEDEP}]
	>=dev-python/joblib-1.3.2[${PYTHON_USEDEP}]
	>=dev-python/lxml-4.9[${PYTHON_USEDEP}]
	dev-python/bibtexparser[${PYTHON_USEDEP}]
	>=dev-python/tabulate-0.9.0[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.67.3[${PYTHON_USEDEP}]
	>=dev-python/requests-2.32.5[${PYTHON_USEDEP}]
"
BDEPEND="
	>=dev-python/cython-3[${PYTHON_USEDEP}]
"
