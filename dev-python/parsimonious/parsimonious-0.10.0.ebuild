# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1

DISTUTILS_USE_PEP621=hatchling
PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 pypi

DESCRIPTION="pure-Python PEG parser"
HOMEPAGE="https://github.com/erikrose/parsimonious/
	https://pypi.org/project/parsimonious/"
#S=${WORKDIR}/${P^}

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="doc"

distutils_enable_tests pytest

python_compile() {
	use doc distutils-r1_python_compile
}

python_test() {
	setup.py test
}

python_install_all() {
	distutils-r1_python_install_all
}
