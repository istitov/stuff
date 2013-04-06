# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit qt4-r2
SRC_URI="mirror://github/pasis/${PN}/${P}.tar.gz"

DESCRIPTION="Environment for executing and debugging Markov algorithm"
HOMEPAGE="https://github.com/pasis/fvm2"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples"

RDEPEND="dev-qt/qtcore
		dev-qt/qtgui"
DEPEND="${RDEPEND}"

src_install() {
		dodoc README
		use doc && dohtml -r docs/ua/html/*
		use examples && dodoc docs/examples/vm_markov_3^x-2y.fvm
		insinto /usr/bin/
		dobin bin/fvm2 || die
}
