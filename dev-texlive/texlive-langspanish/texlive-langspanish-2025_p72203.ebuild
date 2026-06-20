# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TEXLIVE_MODULE_CONTENTS="
	collection-langspanish.r72203
	babel-catalan.r30259
	babel-galician.r30270
	babel-spanish.r77677
	hyphen-catalan.r73410
	hyphen-galician.r73410
	hyphen-spanish.r75447
	quran-es.r74874
"
TEXLIVE_MODULE_DOC_CONTENTS="
	antique-spanish-units.doc.r69568
	babel-catalan.doc.r30259
	babel-galician.doc.r30270
	babel-spanish.doc.r77677
	es-tex-faq.doc.r15878
	hyphen-spanish.doc.r75447
	l2tabu-spanish.doc.r15878
	latex2e-help-texinfo-spanish.doc.r75712
	latexcheat-esmx.doc.r36866
	lshort-spanish.doc.r35050
	quran-es.doc.r74874
	texlive-es.doc.r74997
"
TEXLIVE_MODULE_SRC_CONTENTS="
	babel-catalan.source.r30259
	babel-galician.source.r30270
	babel-spanish.source.r77677
	hyphen-galician.source.r73410
	hyphen-spanish.source.r75447
"

inherit texlive-module

DESCRIPTION="TeXLive Spanish"

LICENSE="CC-BY-4.0 LPPL-1.3 LPPL-1.3c MIT TeX-other-free public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
COMMON_DEPEND="
	>=dev-texlive/texlive-basic-2025
"
RDEPEND="
	${COMMON_DEPEND}
"
DEPEND="
	${COMMON_DEPEND}
"
