# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TEXLIVE_MODULE_CONTENTS="
	collection-langportuguese.r73303
	babel-portuges.r77682
	feupphdteses.r30962
	hyphen-portuguese.r78069
	numberpt.r76924
	ordinalpt.r15878
	ptlatexcommands.r67125
"
TEXLIVE_MODULE_DOC_CONTENTS="
	babel-portuges.doc.r77682
	beamer-tut-pt.doc.r15878
	cursolatex.doc.r24139
	feupphdteses.doc.r30962
	latex-via-exemplos.doc.r78322
	latexcheat-ptbr.doc.r15878
	lshort-portuguese.doc.r55643
	numberpt.doc.r76924
	ordinalpt.doc.r15878
	ptlatexcommands.doc.r67125
	xypic-tut-pt.doc.r15878
"
TEXLIVE_MODULE_SRC_CONTENTS="
	babel-portuges.source.r77682
	numberpt.source.r76924
	ordinalpt.source.r15878
	ptlatexcommands.source.r67125
"

inherit texlive-module

DESCRIPTION="TeXLive Portuguese"

LICENSE="GPL-1+ GPL-2+ LPPL-1.3 LPPL-1.3c MIT public-domain"
SLOT="0"
KEYWORDS="~amd64"
COMMON_DEPEND="
	>=dev-texlive/texlive-basic-2026
"
RDEPEND="
	${COMMON_DEPEND}
"
DEPEND="
	${COMMON_DEPEND}
"
