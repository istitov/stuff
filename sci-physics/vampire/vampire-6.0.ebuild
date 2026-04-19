# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Atomistic simulation of magnetic nanomaterials"
HOMEPAGE="http://vampire.york.ac.uk/"
SRC_URI="https://github.com/richard-evans/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	doc? ( http://vampire.york.ac.uk/resources/vampire-manual.pdf -> ${P}-manual.pdf )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"

PATCHES=( "${FILESDIR}/${P}-cstdint.patch" )

src_prepare() {
	default
	# Drop hard-coded -O0/-fprofile-arcs etc; respect CXXFLAGS.
	sed -i \
		-e "s|^GCC=.*|GCC=$(tc-getCXX) -DCOMP='\"GNU C++ Compiler\"'|" \
		makefile || die
}

src_compile() {
	emake serial
}

src_install() {
	dobin vampire-serial
	dodoc readme.md
	if use doc; then
		newdoc "${DISTDIR}/${P}-manual.pdf" vampire-manual.pdf
	fi
}
