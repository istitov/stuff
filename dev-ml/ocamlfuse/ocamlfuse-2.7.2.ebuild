# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit dune toolchain-funcs

DESCRIPTION="OCaml binding for fuse"
HOMEPAGE="
	https://sourceforge.net/projects/ocamlfuse/
	https://github.com/astrada/ocamlfuse
	https://opam.ocaml.org/packages/ocamlfuse
"
SRC_URI="https://github.com/astrada/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE="ocamlopt"

RDEPEND="
	dev-ml/camlidl:=
	sys-fs/fuse:0
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-ml/dune-configurator
	dev-ml/opam
"

src_compile() {
	tc-export CPP
	dune_src_compile
}
