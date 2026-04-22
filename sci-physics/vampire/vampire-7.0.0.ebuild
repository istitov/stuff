# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Atomistic simulation of magnetic nanomaterials"
HOMEPAGE="http://vampire.york.ac.uk/"
SRC_URI="https://github.com/richard-evans/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

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
}
