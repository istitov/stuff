# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python2_7 python3_{6..11} )

inherit distutils-r1 flag-o-matic

MY_PN="PyCifRW"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Reading and writing CIF (Crystallographic Information Format) files"
HOMEPAGE="https://pypi.org/project/PyCifRW/ https://bitbucket.org/jamesrhester/pycifrw/wiki/Home"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="ASRP"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}/${MY_P}"

python_compile() {
	distutils-r1_python_compile
}

python_test() {
	setup.py test
}

python_install_all() {
	distutils-r1_python_install_all
}
