# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit distutils-r1 flag-o-matic

DESCRIPTION="Software for XRF data analysis"
HOMEPAGE="https://xraypy.github.io/xraylarch"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc python"

RDEPEND="
	>=dev-python/numpy-1.15
	>=sci-libs/scipy-1.1
	>=dev-python/six-1.10
	>=dev-python/sqlalchemy-0.9
	>=dev-python/h5py-2.8
	>=sci-libs/scikits_learn-0.18
	>=dev-python/pillow-3.4
	>=dev-python/PeakUtils-1.3.0
	>=dev-python/requests-2.1
	>=sci-libs/lmfit-3.4
	>=dev-python/uncertainties-3.0.3
	>=dev-python/asteval-0.9.13
	dev-python/pyyaml
	dev-python/psutil
	dev-python/termcolor
	dev-python/wxpython:*
	dev-python/wxmplot
	dev-python/wxutils
	sci-libs/scikits_image
	dev-python/silx
	dev-python/pyFAI
	dev-python/fabio
	sci-libs/pycifrw
"
#	>=dev-python/matplotlib-3.0

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"
#	dev-python/pyepics
#	dev-python/tomopy
#for EPICS pyepics, psycopg2, epicsscan

python_compile() {
	distutils-r1_python_compile
}

python_compile_all() {
	use doc && setup.py build
}

python_test() {
	setup.py test
}

python_install_all() {
	distutils-r1_python_install_all
}
