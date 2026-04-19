# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 virtualx pypi

DESCRIPTION="Interactive analysis of multidimensional datasets tools"
HOMEPAGE="https://hyperspy.org/"
SRC_URI="$(pypi_sdist_url "${PN}" "${PV}")"
S=${WORKDIR}/${P}

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
#IUSE="mrcz tests"
IUSE="cuda python doc +learning gui-jupyter speed gui-traitsui mrcz test"

RDEPEND="
	dev-python/cloudpickle[${PYTHON_USEDEP}]
	>=dev-python/dask-0.18[${PYTHON_USEDEP}]
	>=dev-python/importlib-metadata-3.6[${PYTHON_USEDEP}]
	dev-python/jinja2[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.1[${PYTHON_USEDEP}]
	dev-python/natsort[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.22[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	>=dev-python/pint-0.10[${PYTHON_USEDEP}]
	>=dev-python/rosettasciio-0.12.0[${PYTHON_USEDEP}]
	dev-python/prettytable[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.8[${PYTHON_USEDEP}]
	dev-python/sympy[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	>=dev-python/traits-6.4.0[${PYTHON_USEDEP}]

	>=dev-python/scikit-image-0.15[${PYTHON_USEDEP}]

	dev-python/ipyparallel[${PYTHON_USEDEP}]
	>=dev-python/ipython-7.0[${PYTHON_USEDEP}]

	doc? ( >=app-misc/sphinx-1.7 dev-python/sphinx-rtd-theme )
	learning? ( dev-python/scikit-learn[${PYTHON_USEDEP}] )
	speed? ( >=dev-python/numba-0.56.0[${PYTHON_USEDEP}]
		dev-python/cython[${PYTHON_USEDEP}]
		dev-python/numexpr[${PYTHON_USEDEP}] )
	cuda? ( dev-python/cupy[${PYTHON_USEDEP}] )
"
	##
	##mrcz? ( >=dev-python/blosc-1.5 >=dev-python/mrcz-0.3.6 )
	#	<dev-python/matplotlib-3.5[${PYTHON_USEDEP}]

#	>=dev-python/pyface-7.4.1[${PYTHON_USEDEP}]
#	dev-python/requests[${PYTHON_USEDEP}]

#	dev-python/dill[${PYTHON_USEDEP}]
#	>=dev-python/h5py-2.3[${PYTHON_USEDEP}]
#	>=dev-python/python-dateutil-2.5.0[${PYTHON_USEDEP}]
#	dev-python/ipyparallel[${PYTHON_USEDEP}]
#

#	dev-python/statsmodels[${PYTHON_USEDEP}]
#
#	dev-python/sparse[${PYTHON_USEDEP}]
#	dev-python/imageio[${PYTHON_USEDEP}]
#	dev-python/zarr[${PYTHON_USEDEP}]
#	dev-python/matplotlib_scalebar[${PYTHON_USEDEP}]
#	!dev-python/PTable
#	>=dev-python/tifffile-2019.12.3[${PYTHON_USEDEP}]

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
	test? (
		dev-python/pooch[${PYTHON_USEDEP}]
		>=dev-python/pytest-3.6[${PYTHON_USEDEP}]
		dev-python/pytest-mpl[${PYTHON_USEDEP}]
		dev-python/pytest-xdist[${PYTHON_USEDEP},-test]
		dev-python/pytest-rerunfailures[${PYTHON_USEDEP}]
		dev-python/pytest-timeout[${PYTHON_USEDEP},-test]
	)
"

PDEPEND="
	gui-jupyter? ( >=dev-python/hyperspy-gui-ipywidgets-2.0 )
	gui-traitsui? ( >=dev-python/hyperspy-gui-traitsui-2.0 )
"
#"ipympl",

#baseline = [
#    "pybaselines"
#coverage = [
#    "pytest-cov",
#]
#dask-image = [
#    "dask-image",
#]

#doc = [
#    "holospy", # example gallery
#    "IPython", # Needed in testing code in basic_usage.rst
#    "numpydoc",
#    "pybaselines", # for docstring test
#    "pydata_sphinx_theme",
#    "scikit-image",
#    "setuptools_scm",
#    "sphinx-copybutton",
#    "sphinx-design",
#    "sphinx-favicon",
#    "sphinx-gallery",
#    "sphinx>=1.7",
#    "sphinxcontrib-mermaid",
#    "sphinxcontrib-towncrier>=0.5.0a0",
#    "towncrier",
#]

#odr = [
#    "odrpack>=0.3.1",
#]

PATCHES=(
	"${FILESDIR}"/9f7e7e144ccfa399b4c447b956d3818c4f701f10.patch
)

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

python_test() {
	virtx epytest
}
