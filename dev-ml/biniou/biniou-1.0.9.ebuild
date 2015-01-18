# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit findlib

DESCRIPTION="A binary JSON like data format for OCaml"
HOMEPAGE="http://mjambon.com/biniou.html"
SRC_URI="http://mjambon.com/releases/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND="dev-lang/ocaml
		dev-ml/easy-format"

RDEPEND="${DEPEND}"

src_compile() {
	emake -j1
	use doc && make html
}

src_install() {
	findlib_src_preinst
	mkdir "${D}/usr/bin"
	emake install PREFIX="${D}/usr"
	use doc && dohtml -r html/
}
