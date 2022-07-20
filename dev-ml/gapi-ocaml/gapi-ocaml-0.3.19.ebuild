# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

#inherit oasis

OASIS_BUILD_DOCS=1
DESCRIPTION="A simple OCaml client for Google Services"
HOMEPAGE="http://gapi-ocaml.forge.ocamlcore.org/"
SRC_URI="https://github.com/astrada/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc test"

RDEPEND=">=dev-lang/ocaml-4.02.3:=
	>=dev-ml/findlib-1.2.7:=
	>=dev-ml/ocurl-0.5.3:=
	>=dev-ml/ocamlnet-4.1.4:=
	>=dev-ml/cryptokit-1.3.14:=
	>=dev-ml/extlib-1.5.1:=
	>=dev-ml/yojson-1.0.2:=
	>=dev-ml/xmlm-1.0.2:="
DEPEND="${RDEPEND}
	test? ( dev-ml/ounit2 )"
DOCS=( "README.md" )
