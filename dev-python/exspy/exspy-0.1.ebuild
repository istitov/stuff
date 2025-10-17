# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 flag-o-matic virtualx pypi

DESCRIPTION="EELS and EDS analysis with the HyperSpy framework"
HOMEPAGE="https://github.com/hyperspy/exspy"
SRC_URI="$(pypi_sdist_url "${PN}" "${PV}")"
S=${WORKDIR}/${P}

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
#IUSE="mrcz tests"
IUSE="python doc test"

RDEPEND="
	dev-python/hyperspy[${PYTHON_USEDEP}]
	dev-python/dask[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/numexpr[${PYTHON_USEDEP}]
	dev-python/Pint[${PYTHON_USEDEP}]
	dev-python/traits[${PYTHON_USEDEP}]
"
#pooch

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
	test? ( >=dev-python/pytest-3.6[${PYTHON_USEDEP}]
		dev-python/pytest-mpl[${PYTHON_USEDEP}]
		dev-python/pytest-xdist[${PYTHON_USEDEP},-test]
		dev-python/pytest-rerunfailures[${PYTHON_USEDEP}]
		dev-python/pytest-timeout[${PYTHON_USEDEP},-test]
	)
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

python_compile() {
	distutils-r1_python_compile
}

python_compile_all() {
	use doc && setup.py build
}

python_test() {
	virtx epytest
}

python_install_all() {
	distutils-r1_python_install_all
}
