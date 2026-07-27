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

# Retained below last-two on purpose: this is the last FUSE-2 release.
# Upstream's own opam metadata moves from "ocamlfuse" {>= "2.7.2"} to
# "fuse3" {>= "3.10.0"} exactly at 0.9.0, so 0.8.x and 0.9.x are two
# different bindings rather than a plain version progression, and 0.8.2 is
# the only remaining consumer of dev-ml/ocamlfuse anywhere in the tree -
# dropping it orphans that package as well as removing the FUSE-2 path.
# bin/retention-audit.py cannot infer this: it buckets a series by the
# first dotted component, so every 0.x version collapses into one bucket
# and its last-of-earlier-series rule never fires here. Carried there as
# an explicit override instead. verified 2026-07-28

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64"
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
