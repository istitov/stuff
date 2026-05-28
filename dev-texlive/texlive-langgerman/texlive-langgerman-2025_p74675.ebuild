# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TEXLIVE_MODULE_CONTENTS="
	collection-langgerman.r74675
	apalike-german.r76790
	autotype.r76924
	babel-german.r77819
	bibleref-german.r21923
	dehyph.r48599
	dehyph-exptl.r72949
	dhua.r24035
	dtk-bibliography.r76870
	german.r42428
	germbib.r76790
	germkorr.r15878
	hausarbeit-jura.r56070
	hyphen-german.r74203
	milog.r75447
	quran-de.r74874
	r_und_s.r15878
	schulmathematik.r76924
	termcal-de.r47111
	udesoftec.r57866
	uhrzeit.r39570
	umlaute.r15878
	fragoli.r76924
"
TEXLIVE_MODULE_DOC_CONTENTS="
	apalike-german.doc.r76790
	autotype.doc.r76924
	babel-german.doc.r77819
	bibleref-german.doc.r21923
	booktabs-de.doc.r21907
	csquotes-de.doc.r23371
	dehyph-exptl.doc.r72949
	dhua.doc.r24035
	dtk-bibliography.doc.r76870
	etdipa.doc.r76924
	etoolbox-de.doc.r21906
	fifinddo-info.doc.r29349
	german.doc.r42428
	germbib.doc.r76790
	germkorr.doc.r15878
	hausarbeit-jura.doc.r56070
	koma-script-examples.doc.r63833
	l2picfaq.doc.r19601
	l2tabu.doc.r63708
	latexcheat-de.doc.r35702
	lshort-german.doc.r70740
	lualatex-doc-de.doc.r30474
	microtype-de.doc.r54080
	milog.doc.r75447
	quran-de.doc.r74874
	r_und_s.doc.r15878
	schulmathematik.doc.r76924
	templates-fenn.doc.r15878
	templates-sommer.doc.r15878
	termcal-de.doc.r47111
	texlive-de.doc.r74226
	tipa-de.doc.r22005
	translation-arsclassica-de.doc.r23803
	translation-biblatex-de.doc.r59382
	translation-chemsym-de.doc.r23804
	translation-ecv-de.doc.r24754
	translation-enumitem-de.doc.r24196
	translation-europecv-de.doc.r23840
	translation-filecontents-de.doc.r24010
	translation-moreverb-de.doc.r23957
	udesoftec.doc.r57866
	uhrzeit.doc.r39570
	umlaute.doc.r15878
	voss-mathcol.doc.r32954
	fragoli.doc.r76924
"
TEXLIVE_MODULE_SRC_CONTENTS="
	babel-german.source.r77819
	dhua.source.r24035
	fifinddo-info.source.r29349
	german.source.r42428
	hausarbeit-jura.source.r56070
	termcal-de.source.r47111
	udesoftec.source.r57866
	umlaute.source.r15878
"

inherit texlive-module

DESCRIPTION="TeXLive German"

LICENSE="FDL-1.1+ GPL-1+ LPPL-1.0 LPPL-1.3 LPPL-1.3c MIT OPL TeX-other-free"
SLOT="0"
KEYWORDS="~amd64"
COMMON_DEPEND="
	>=dev-texlive/texlive-basic-2025
"
RDEPEND="
	${COMMON_DEPEND}
"
DEPEND="
	${COMMON_DEPEND}
"
