# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 flag-o-matic pypi

DESCRIPTION="This package provides utilities related to the detection of peaks on 1D data."
HOMEPAGE="https://pypi.org/project/PeakUtils/
	https://bitbucket.org/lucashnegri/peakutils/"
MYPN="${PN/peakutils/PeakUtils}"
MYP="${MYPN}-${PV}"
SRC_URI="$(pypi_sdist_url --no-normalize "${MYPN}" "${PV}")"
S=${WORKDIR}/${MYP}

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc python"

RDEPEND="
	>=dev-python/numpy-1.8[${PYTHON_USEDEP}]
	>=dev-python/scipy-0.11[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
"
#dev-python/PyQt4

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

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
