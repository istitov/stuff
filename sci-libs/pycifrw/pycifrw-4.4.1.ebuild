# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python2_7 python3_{6..11} )

inherit distutils-r1 flag-o-matic pypi

MY_PN="PyCifRW"
MY_P="${MY_PN}-${PV}"
SRC_URI="$(pypi_sdist_url --no-normalize "${MY_PN}" "${PV}")"
S=${WORKDIR}/${MY_P}

DESCRIPTION="Reading and writing CIF (Crystallographic Information Format) files"


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
