# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Atomistic simulation of magnetic nanomaterials"
HOMEPAGE="https://www-users.york.ac.uk/~rfle500/research/vampire/"
SRC_URI="https://github.com/richard-evans/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

PATCHES=( "${FILESDIR}/${P}-cstdint.patch" )

src_prepare() {
	default
	# Drop hard-coded optimization and profiling flags.
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
