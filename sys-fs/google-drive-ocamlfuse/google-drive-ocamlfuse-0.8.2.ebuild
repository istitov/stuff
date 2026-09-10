# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit dune findlib

DESCRIPTION="FUSE filesystem over Google Drive"
HOMEPAGE="
	https://github.com/astrada/google-drive-ocamlfuse
	https://opam.ocaml.org/packages/google-drive-ocamlfuse/
"
SRC_URI="https://github.com/astrada/${PN}/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz"

# Keep the last FUSE 2 release; 0.9 switches from ocamlfuse to fuse3. This also
# preserves the tree's only ocamlfuse consumer. retention-audit groups all 0.x
# releases together, so this exception is explicit. verified 2026-07-28

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64"
IUSE="ocamlopt test"

RDEPEND="
	>=dev-ml/gapi-ocaml-0.4.9:=
	>=dev-ml/ocamlfuse-2.7.2:=
	dev-ml/cryptokit:=
	dev-ml/extlib:=
	dev-ml/ocaml-sqlite3:=
	dev-ml/otoml:=
	>=dev-ml/tiny_httpd-0.6:=
"
DEPEND="
	${RDEPEND}
	dev-ml/camlidl:=
	test? ( dev-ml/ounit2 )
"

RESTRICT="!test? ( test )"
