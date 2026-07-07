# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TEXLIVE_MODULE_CONTENTS="
	collection-langitalian.r79075
	antanilipsum.r77161
	babel-italian.r77371
	codicefiscaleitaliano.r29803
	fixltxhyph.r73227
	frontespizio.r24054
	hyphen-italian.r78069
	itnumpar.r78793
	layaureo.r19087
	verifica.r75682
	attinormativi.r79199
"
TEXLIVE_MODULE_DOC_CONTENTS="
	amsldoc-it.doc.r45662
	amsmath-it.doc.r22930
	amsthdoc-it.doc.r45662
	antanilipsum.doc.r77161
	babel-italian.doc.r77371
	codicefiscaleitaliano.doc.r29803
	fancyhdr-it.doc.r21912
	fixltxhyph.doc.r73227
	frontespizio.doc.r24054
	itnumpar.doc.r78793
	l2tabu-italian.doc.r25218
	latex4wp-it.doc.r36000
	layaureo.doc.r19087
	lshort-italian.doc.r79461
	psfrag-italian.doc.r15878
	texlive-it.doc.r58653
	verifica.doc.r75682
	attinormativi.doc.r79199
"
TEXLIVE_MODULE_SRC_CONTENTS="
	antanilipsum.source.r77161
	babel-italian.source.r77371
	codicefiscaleitaliano.source.r29803
	fixltxhyph.source.r73227
	frontespizio.source.r24054
	itnumpar.source.r78793
	layaureo.source.r19087
	verifica.source.r75682
	attinormativi.source.r79199
"

inherit texlive-module

DESCRIPTION="TeXLive Italian"

LICENSE="FDL-1.1+ GPL-1+ LGPL-2+ LPPL-1.3 LPPL-1.3c TeX-other-free"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
COMMON_DEPEND="
	>=dev-texlive/texlive-basic-2026
"
RDEPEND="
	${COMMON_DEPEND}
"
DEPEND="
	${COMMON_DEPEND}
"
