# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

EGIT_REPO_URI="git://github.com/astrada/ocamlfuse.git"

inherit oasis git-r3

DESCRIPTION="OCaml binding for fuse"
HOMEPAGE="https://sourceforge.net/projects/ocamlfuse/"
SRC_URI="https://github.com/astrada/${PN}/archive/v${PV}_cvs2.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=dev-ml/camlidl-0.9.5
	dev-lang/ocaml
	sys-fs/fuse"
RDEPEND="${DEPEND}"
S="${WORKDIR}/${P}-cvs~oasis1"

DOCS=( "README.md" )
