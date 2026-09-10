# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit latex-package

DESCRIPTION="Create glossaries and lists of acronyms"
HOMEPAGE="https://www.ctan.org/pkg/glossaries/"
# CTAN's mutable, unversioned zip cannot back a reproducible Manifest, and the
# Gentoo mirror lacks 5.1. Use a 193 KiB source-only bundle containing the
# generators, makeglossaries, and CHANGES; omit bulky manuals and samples.
# verified 2026-07-28
MY_BUNDLE="${PN}-${PV}-src"
SRC_URI="https://raw.githubusercontent.com/istitov/extra-stuff/${MY_BUNDLE}-r0-0/dev-tex/${PN}/${MY_BUNDLE}.tar.xz
	-> ${MY_BUNDLE}-r0-0.tar.xz"

S=${WORKDIR}/${PN}

LICENSE="LPPL-1.2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-lang/perl
	dev-texlive/texlive-latexrecommended
	>=dev-texlive/texlive-latexextra-2012
	dev-texlive/texlive-plaingeneric
"
BDEPEND="
	${RDEPEND}
"

TEXMF="/usr/share/texmf-dist"

src_install() {
	latex-package_src_doinstall styles

	dobin makeglossaries

	dodoc CHANGES
}

pkg_postinst() {
	elog "This package installs the glossaries styles and the makeglossaries"
	elog "script only. The user manual, the code manual and the sample"
	elog "documents are not installed: upstream ships them in a 16 MiB archive"
	elog "that CTAN publishes without a version in the filename, so this"
	elog "package is built from a source-only bundle instead."
	elog
	elog "The manuals are at https://www.ctan.org/pkg/glossaries and are also"
	elog "readable with: texdoc glossaries"
}
