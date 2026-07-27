# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Perl script for automatically building LaTeX documents"
HOMEPAGE="https://personal.psu.edu/~jcc8/software/latexmk/
		  https://ctan.org/pkg/latexmk/"
SRC_URI="https://www.cantab.net/users/johncollins/${PN}/${P/./}.zip"

S="${WORKDIR}/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-lang/perl
	virtual/latex-base
"

DEPEND="${RDEPEND}"

BDEPEND="app-arch/unzip"

src_install() {
	newbin latexmk.pl latexmk
	doman latexmk.1
	dodoc CHANGES README latexmk.pdf latexmk.txt
	dodoc -r example_rcfiles extra-scripts
}
