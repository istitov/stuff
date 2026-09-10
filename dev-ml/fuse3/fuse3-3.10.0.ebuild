# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit dune toolchain-funcs

DESCRIPTION="OCaml bindings for FUSE 3 (Filesystem in UserSpacE)"
HOMEPAGE="
	https://github.com/astrada/ocamlfuse
	https://opam.ocaml.org/packages/fuse3/
"
# The package was renamed to fuse3, but release archives remain ocamlfuse-${PV}.
SRC_URI="https://github.com/astrada/ocamlfuse/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/ocamlfuse-${PV}"

# LICENSE contains GPL-2 despite opam declaring GPL-1+. Verified 2026-06-23.
LICENSE="GPL-2"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64"
IUSE="ocamlopt"

RDEPEND="
	!dev-ml/ocamlfuse
	dev-ml/camlidl:=
	>=sys-fs/fuse-3.10.0:3
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-ml/dune-configurator
	virtual/pkgconfig
"

PATCHES=( "${FILESDIR}/${P}-no-opam-probe.patch" )

src_compile() {
	tc-export CPP
	dune_src_compile
}
