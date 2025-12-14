# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python2_7 python3_{9..14} )

inherit distutils-r1 pypi

MY_PN="PyCifRW"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Reading and writing CIF (Crystallographic Information Format) files"
HOMEPAGE="https://pypi.org/project/PyCifRW/ https://bitbucket.org/jamesrhester/pycifrw/wiki/Home"
SRC_URI="https://github.com/jamesrhester/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}"

S="${WORKDIR}/${MY_P}"

LICENSE="ASRP"
SLOT="0"
KEYWORDS="~amd64 ~x86"

python_compile() {
	distutils-r1_python_compile
}

python_test() {
	setup.py test
}

python_install_all() {
	distutils-r1_python_install_all
}
