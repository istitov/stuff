# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic texlive-common

DESCRIPTION="8-bit Implementation of BibTeX 0.99 with a Very Large Capacity"
HOMEPAGE="https://tug.org/texlive/"
# 2025 hardcoded in the historic URL; bump on TL2026 adoption.
SRC_URI="
	https://mirrors.ctan.org/systems/texlive/Source/texlive-${PV#*_p}-source.tar.xz
	https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/texlive-${PV#*_p}-source.tar.xz
	https://dev.gentoo.org/~flow/distfiles/texlive/texlive-${PV#*_p}-source.tar.xz
"

TL_REVISION=66186
EXTRA_TL_MODULES="bibtex8.r${TL_REVISION} bibtexu.r${TL_REVISION}"
EXTRA_TL_DOC_MODULES="bibtex8.doc.r${TL_REVISION} bibtexu.doc.r${TL_REVISION}"

texlive-common_append_to_src_uri EXTRA_TL_MODULES

SRC_URI="${SRC_URI} doc? ( "
texlive-common_append_to_src_uri EXTRA_TL_DOC_MODULES
SRC_URI="${SRC_URI} ) "

S="${WORKDIR}"/texlive-${PV#*_p}-source/texk/bibtex-x
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 ~arm64"

IUSE="doc source"

RDEPEND="
	>=dev-libs/kpathsea-6.2.1:=
	>=dev-libs/icu-4.4:=
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	# bug #943986
	append-cflags -std=gnu17

	econf \
		--with-system-kpathsea \
		--with-system-icu
}

src_install() {
	emake \
		DESTDIR="${D}" \
		csfdir="${EPREFIX}/usr/share/texmf-dist/bibtexu/csf/base" \
		btdocdir="${EPREFIX}/usr/share/doc/${PF}" \
		install
	dodoc 00bibtex8-readme.txt 00bibtex8-history.txt ChangeLog csf/csfile.txt

	dodir /usr/share # just in case
	cp -pR "${WORKDIR}"/texmf-dist "${ED}/usr/share/" || die "failed to install texmf trees"
	if use source ; then
		cp -pR "${WORKDIR}"/tlpkg "${ED}/usr/share/" || die "failed to install tlpkg files"
	fi
}
