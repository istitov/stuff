# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

EGIT_REPO_URI="https://github.com/astrada/ocamlfuse.git"

inherit oasis git-r3

DESCRIPTION="OCaml binding for fuse"
HOMEPAGE="https://sourceforge.net/projects/ocamlfuse/"
SRC_URI="https://github.com/astrada/${PN}/archive/v${PV}_cvs5.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-ml/camlidl-0.9.5
	dev-lang/ocaml
	sys-fs/fuse:0"
RDEPEND="${DEPEND}"
#S="${WORKDIR}/${P}-v2.7.1_cvs4"

DOCS=( "README.md" )
