# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
#PYPI_NO_NORMALIZE=0
PYPI_PN="abtem"
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..11} )

inherit distutils-r1 pypi virtualx

DESCRIPTION="ab initio transmission electron microscopy"
HOMEPAGE="https://github.com/abTEM/abTEM"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="python test"

RDEPEND="
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	>=dev-python/dask-2022.12.1[${PYTHON_USEDEP}]
	dev-python/zarr[${PYTHON_USEDEP}]
	dev-python/ipympl[${PYTHON_USEDEP}]
	dev-python/ipywidgets[${PYTHON_USEDEP}]
	dev-python/jupyterlab[${PYTHON_USEDEP}]
	dev-python/jupyterlab-widgets[${PYTHON_USEDEP}]
	dev-python/ase[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/pandas[${PYTHON_USEDEP}]
	dev-python/bokeh[${PYTHON_USEDEP}]
	dev-python/distributed[${PYTHON_USEDEP}]
	dev-python/dask-labextension[${PYTHON_USEDEP}]
	dev-python/pyFFTW[${PYTHON_USEDEP}]
	dev-python/tabulate[${PYTHON_USEDEP}]
	dev-python/hypothesis[${PYTHON_USEDEP}]
	<dev-python/numpy-2.0[${PYTHON_USEDEP}]
"
#	dev-python/strategies[${PYTHON_USEDEP}]
DEPEND="${RDEPEND}
"

#PATCHES=(
#	"${FILESDIR}"/scan.patch
#)
##

src_prepare() {
	#all for numpy-2.0
	#sed -i 's/\r$//' abtem/scan.py || die
	#eapply "${FILESDIR}/scan2.patch"
	#sed -i -e 's:import strategies :from . import strategies :' test/*.py || die
	#sed -i -e "s:wrapped.itemset(0, x):wrapped[0] = x:" abtem/core/ensemble.py || die
	#sed -i -e "s:artists.itemset(i, artist):artists[i] = artist:" abtem/visualize/visualizations.py || die
	default
}

python_test() {
	virtx epytest
}
