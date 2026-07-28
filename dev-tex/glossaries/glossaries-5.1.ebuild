# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit latex-package

DESCRIPTION="Create glossaries and lists of acronyms"
HOMEPAGE="https://www.ctan.org/pkg/glossaries/"
# CTAN publishes this only as an unversioned glossaries.zip, whose content
# changes under a fixed filename and so cannot back a reproducible Manifest,
# and gentoo's dev mirror carries 4.55 but not 5.1. Re-hosted on extra-stuff
# as a source-only bundle instead: glossaries.ins and glossaries.dtx generate
# the 57 style files we install (plus sample .tex files the eclass skips),
# makeglossaries is a shipped script rather than a generated one, and CHANGES
# is installed as documentation. The user and code manuals and the sample
# documents are omitted -- they are the bulk of the 16 MiB upstream archive
# against 193 KB here. verified 2026-07-28
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
