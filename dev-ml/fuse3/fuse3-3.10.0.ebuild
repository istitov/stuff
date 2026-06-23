# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit dune toolchain-funcs

DESCRIPTION="OCaml bindings for FUSE 3 (Filesystem in UserSpacE)"
HOMEPAGE="
	https://github.com/astrada/ocamlfuse
	https://opam.ocaml.org/packages/fuse3/
"
# Upstream renamed the opam package ocamlfuse (FUSE 2) -> fuse3 (FUSE 3)
# at v3.x but kept the GitHub repo name "ocamlfuse"; the tarball unpacks
# to ocamlfuse-${PV}.
SRC_URI="https://github.com/astrada/ocamlfuse/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/ocamlfuse-${PV}"

# LICENSE file ships GPL v2 verbatim; the fuse3.opam metadata's
# "GPL-1.0-or-later" is looser than the actual file. verified 2026-06-23
LICENSE="GPL-2"
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE="ocamlopt"

RDEPEND="
	dev-ml/camlidl:=
	>=sys-fs/fuse-3.10.0:3
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-ml/dune-configurator
	virtual/pkgconfig
"

src_compile() {
	tc-export CPP
	dune_src_compile
}
