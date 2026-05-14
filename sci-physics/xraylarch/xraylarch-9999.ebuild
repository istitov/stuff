# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 git-r3

DESCRIPTION="Software for analysis of X-ray absorption and fluorescence data"
HOMEPAGE="
	https://xraypy.github.io/xraylarch/
	https://github.com/xraypy/xraylarch/
"
EGIT_REPO_URI="https://github.com/xraypy/xraylarch.git"

LICENSE="GPL-2"
SLOT="0"
# Upstream tests are largely network-driven (AMCSD, MP API, XrayDB
# remote queries) and expect the full lmfit/hyperspy/... fixtures.
RESTRICT="test"

# The wx stack (wxpython/wxmplot/wxutils/darkdetect) is needed at runtime
# even for non-GUI use: larch/plot/__init__.py unconditionally imports
# wxmplot_xafsplots, which imports larch.wxlib.plotter once wxpython is
# detectable — and that does an unguarded `from wxmplot import ...`.
# So gating on a wxgui USE flag would silently break `larch` whenever
# wxpython is installed for any reason. Pull the whole stack always.
RDEPEND="
	dev-python/larixite[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/asteval[${PYTHON_USEDEP}]
		dev-python/charset-normalizer[${PYTHON_USEDEP}]
		dev-python/darkdetect[${PYTHON_USEDEP}]
		dev-python/dill[${PYTHON_USEDEP}]
		dev-python/fabio[${PYTHON_USEDEP}]
		dev-python/h5py[${PYTHON_USEDEP}]
		dev-python/hdf5plugin[${PYTHON_USEDEP}]
		dev-python/imageio[${PYTHON_USEDEP}]
		dev-python/lmfit[${PYTHON_USEDEP}]
		dev-python/matplotlib[${PYTHON_USEDEP}]
		dev-python/numdifftools[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/pip[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		dev-python/pyfai[${PYTHON_USEDEP}]
		dev-python/pyshortcuts[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/scikit-image[${PYTHON_USEDEP}]
		dev-python/scikit-learn[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/silx[${PYTHON_USEDEP}]
		dev-python/sqlalchemy[${PYTHON_USEDEP}]
		dev-python/sqlalchemy-utils[${PYTHON_USEDEP}]
		dev-python/tabulate[${PYTHON_USEDEP}]
		dev-python/termcolor[${PYTHON_USEDEP}]
		dev-python/tomli[${PYTHON_USEDEP}]
		dev-python/tomli-w[${PYTHON_USEDEP}]
		dev-python/uncertainties[${PYTHON_USEDEP}]
		dev-python/wxmplot[${PYTHON_USEDEP}]
		dev-python/wxpython:*[${PYTHON_USEDEP}]
		dev-python/wxutils[${PYTHON_USEDEP}]
		dev-python/xraydb[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
BDEPEND="$(python_gen_cond_dep '>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]')"
