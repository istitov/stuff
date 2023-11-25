# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_REPO_URI="https://github.com/astrada/ocamlfuse.git"

inherit git-r3

DESCRIPTION="OCaml binding for fuse"
HOMEPAGE="https://sourceforge.net/projects/ocamlfuse/"
SRC_URI="https://github.com/astrada/${PN}/archive/v${PV}_cvs7.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=dev-ml/camlidl-0.9.5
	dev-lang/ocaml
	sys-fs/fuse:0
	dev-ml/opam"
RDEPEND="${DEPEND}"
#S="${WORKDIR}/${P}-v2.7.1_cvs7"

DOCS=( "README.md" )
