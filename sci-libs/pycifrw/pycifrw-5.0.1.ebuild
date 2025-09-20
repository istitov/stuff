# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python2_7 python3_{6..11} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 flag-o-matic pypi

DESCRIPTION="Reading and writing CIF (Crystallographic Information Format) files"


LICENSE="ASRP"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S=${WORKDIR}/${P}

python_compile() {
	distutils-r1_python_compile
}

python_test() {
	setup.py test
}

python_install_all() {
	distutils-r1_python_install_all
}
