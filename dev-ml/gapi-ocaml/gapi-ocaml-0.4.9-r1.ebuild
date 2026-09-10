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

# opam requires cryptokit>=1.21, while ::gentoo retains older stable versions;
# the other dependency floors cannot bind. verified 2026-07-27
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
