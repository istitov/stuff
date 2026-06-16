# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Atomistic simulation of magnetic nanomaterials"
HOMEPAGE="https://www-users.york.ac.uk/~rfle500/research/vampire/"
SRC_URI="https://github.com/richard-evans/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
# 2026-04-29: USE=doc disabled because vampire.york.ac.uk presents a
# broken SSL chain (Sectigo intermediate not reachable from a default
# CA bundle); portage's fetcher fails. Revisit if the cert is fixed,
# or if upstream relocates the manual to GitHub releases.
#SRC_URI+=" doc? ( https://vampire.york.ac.uk/resources/vampire-manual.pdf -> ${P}-manual.pdf )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
#IUSE="doc"

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
	#use doc && newdoc "${DISTDIR}/${P}-manual.pdf" vampire-manual.pdf
}
