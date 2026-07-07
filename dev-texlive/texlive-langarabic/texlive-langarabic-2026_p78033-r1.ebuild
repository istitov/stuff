# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TEXLIVE_MODULE_CONTENTS="
	collection-langarabic.r78033
	alkalami.r44497
	alpha-persian.r76790
	amiri.r79461
	arabi.r77682
	arabi-add.r67573
	arabic-book.r59594
	arabluatex.r67201
	arabtex.r78101
	bidi.r77682
	bidihl.r77682
	dad.r54191
	ghab.r29803
	hvarabic.r76924
	imsproc.r29803
	iran-bibtex.r76790
	khatalmaqala.r68280
	kurdishlipsum.r77682
	luabidi.r79256
	na-box.r45130
	parsimatn.r70775
	parsinevis.r70776
	persian-bib.r76790
	quran.r78362
	sexam.r46628
	simurgh.r31719
	texnegar.r76924
	tram.r29803
	xepersian.r77682
	xepersian-hm.r77682
	awami.r76980
	fariscovernew.r78508
	mohe-book.r74912
"
TEXLIVE_MODULE_DOC_CONTENTS="
	alkalami.doc.r44497
	alpha-persian.doc.r76790
	amiri.doc.r79461
	arabi.doc.r77682
	arabi-add.doc.r67573
	arabic-book.doc.r59594
	arabluatex.doc.r67201
	arabtex.doc.r78101
	bidi.doc.r77682
	bidihl.doc.r77682
	dad.doc.r54191
	ghab.doc.r29803
	hvarabic.doc.r76924
	imsproc.doc.r29803
	iran-bibtex.doc.r76790
	khatalmaqala.doc.r68280
	kurdishlipsum.doc.r77682
	lshort-persian.doc.r79461
	luabidi.doc.r79256
	na-box.doc.r45130
	parsimatn.doc.r70775
	parsinevis.doc.r70776
	persian-bib.doc.r76790
	quran.doc.r78362
	sexam.doc.r46628
	simurgh.doc.r31719
	texnegar.doc.r76924
	tram.doc.r29803
	xepersian.doc.r77682
	xepersian-hm.doc.r77682
	xindy-persian.doc.r59013
	awami.doc.r76980
	fariscovernew.doc.r78508
	mohe-book.doc.r74912
"
TEXLIVE_MODULE_SRC_CONTENTS="
	arabluatex.source.r67201
	bidi.source.r77682
	texnegar.source.r76924
	xepersian.source.r77682
	xepersian-hm.source.r77682
"

inherit texlive-module

DESCRIPTION="TeXLive Arabic"

LICENSE="CC-BY-SA-4.0 GPL-2 GPL-3+ LPPL-1.3 LPPL-1.3c MIT OFL-1.1 public-domain"
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
