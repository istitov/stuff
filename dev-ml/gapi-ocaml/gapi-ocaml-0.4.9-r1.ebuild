# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit dune

DESCRIPTION="A simple OCaml client for Google Services"
HOMEPAGE="
	https://opam.ocaml.org/packages/gapi-ocaml/
	https://github.com/astrada/gapi-ocaml
"
SRC_URI="https://github.com/astrada/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64"
IUSE="ocamlopt test"

# gapi-ocaml.opam requires cryptokit >= 1.21. The floor is load-bearing rather
# than decorative: ::gentoo's stable cryptokit is 1.16.1-r2, and 1.19, 1.20.1
# and 1.21.1 are all ~arch, so a user who keywords only this package resolves
# five releases below what upstream asks for. The other opam floors cannot
# bind -- yojson >= 1.6.0 against 2.2.2 and 3.0.0 in tree, cppo >= 1.1.0
# against 1.6.7 and up -- so they stay unversioned. verified 2026-07-27
RDEPEND="
	dev-ml/ocurl:=[ocamlopt?]
	>=dev-ml/cryptokit-1.21:=[ocamlopt?]
	dev-ml/yojson:=[ocamlopt?]
	dev-ml/camlp-streams:=[ocamlopt?]
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-ml/cppo
	test? ( dev-ml/ounit2 )
"

RESTRICT="!test? ( test )"
