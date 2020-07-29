# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit opam

DESCRIPTION="Ocaml XML manipulation module"
HOMEPAGE="http://erratique.ch/software/xmlm https://github.com/dbuenzli/xmlm"
SRC_URI="http://erratique.ch/software/${PN}/releases/${P}.tbz"

LICENSE="ISC"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND=""
DEPEND="${RDEPEND}
	dev-ml/findlib
	dev-ml/topkg:="

src_compile() {
	ocaml pkg/pkg.ml build \
		--tests "$(usex test 'true' 'false')" \
		|| die "compile failed"
}

src_test() {
	ocaml pkg/pkg.ml test || die "test failed"
}
