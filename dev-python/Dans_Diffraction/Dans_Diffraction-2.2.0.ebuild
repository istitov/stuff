# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 flag-o-matic

MYPN="${PN/Dans_Diffraction/Dans-Diffraction}"
MYP="${MYPN}-${PV}"

DESCRIPTION="Generate diffracted intensities from crystals"
HOMEPAGE="https://danporter.github.io/Dans_Diffraction/"
SRC_URI="mirror://pypi/${MYP:0:1}/${MYPN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python"

RDEPEND="
	>=dev-python/numpy-1.10[${PYTHON_USEDEP}]
	>=dev-python/scipy-0.15[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

#S="${WORKDIR}/${MYP}"

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
