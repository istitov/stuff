# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TEXLIVE_MODULE_CONTENTS="
	collection-langjapanese.r76651
	ascmac.r53411
	asternote.r63838
	babel-japanese.r57733
	bxbase.r66115
	bxcjkjatype.r67705
	bxcoloremoji.r77677
	bxghost.r66147
	bxjaholiday.r76924
	bxjalipsum.r67620
	bxjaprnind.r59641
	bxjatoucs.r71870
	bxjscls.r75447
	bxorigcapt.r64072
	bxwareki.r67594
	convbkmk.r49252
	endnotesj.r77677
	gckanbun.r77307
	gentombow.r77677
	haranoaji.r76078
	haranoaji-extra.r76079
	ieejtran.r76790
	ifptex.r77677
	ifxptex.r46153
	ipaex.r61719
	japanese-mathformulas.r64678
	japanese-otf.r77677
	jieeetran.r76924
	jlreq.r77677
	jlreq-deluxe.r76924
	jpneduenumerate.r72898
	jpnedumathsymbols.r72959
	jsclasses.r77677
	kanbun.r77677
	luatexja.r78116
	mendex-doc.r75172
	morisawa.r77677
	pbibtex-base.r66085
	platex.r77677
	platex-tools.r72097
	plautopatch.r77677
	ptex.r73848
	ptex-base.r64072
	ptex-fontmaps.r65953
	ptex-fonts.r64330
	ptex2pdf.r65953
	pxbase.r77677
	pxchfon.r77677
	pxcjkcat.r77677
	pxjahyper.r77677
	pxjodel.r77677
	pxrubrica.r66298
	pxufont.r77677
	uplatex.r77677
	uptex.r73848
	uptex-base.r76790
	uptex-fonts.r74119
	wadalab.r42428
	zxjafbfont.r77677
	zxjatype.r77677
"
TEXLIVE_MODULE_DOC_CONTENTS="
	ascmac.doc.r53411
	asternote.doc.r63838
	babel-japanese.doc.r57733
	bxbase.doc.r66115
	bxcjkjatype.doc.r67705
	bxcoloremoji.doc.r77677
	bxghost.doc.r66147
	bxjaholiday.doc.r76924
	bxjalipsum.doc.r67620
	bxjaprnind.doc.r59641
	bxjatoucs.doc.r71870
	bxjscls.doc.r75447
	bxorigcapt.doc.r64072
	bxwareki.doc.r67594
	convbkmk.doc.r49252
	endnotesj.doc.r77677
	gckanbun.doc.r77307
	gentombow.doc.r77677
	haranoaji.doc.r76078
	haranoaji-extra.doc.r76079
	ieejtran.doc.r76790
	ifptex.doc.r77677
	ifxptex.doc.r46153
	ipaex.doc.r61719
	japanese-mathformulas.doc.r64678
	japanese-otf.doc.r77677
	jieeetran.doc.r76924
	jlreq.doc.r77677
	jlreq-deluxe.doc.r76924
	jpneduenumerate.doc.r72898
	jpnedumathsymbols.doc.r72959
	jsclasses.doc.r77677
	kanbun.doc.r77677
	lshort-japanese.doc.r36207
	luatexja.doc.r78116
	mendex-doc.doc.r75172
	morisawa.doc.r77677
	pbibtex-base.doc.r66085
	pbibtex-manual.doc.r66181
	platex.doc.r77677
	platex-tools.doc.r72097
	platexcheat.doc.r49557
	plautopatch.doc.r77677
	ptex.doc.r73848
	ptex-base.doc.r64072
	ptex-fontmaps.doc.r65953
	ptex-fonts.doc.r64330
	ptex-manual.doc.r75173
	ptex2pdf.doc.r65953
	pxbase.doc.r77677
	pxchfon.doc.r77677
	pxcjkcat.doc.r77677
	pxjahyper.doc.r77677
	pxjodel.doc.r77677
	pxrubrica.doc.r66298
	pxufont.doc.r77677
	texlive-ja.doc.r74739
	uplatex.doc.r77677
	uptex.doc.r73848
	uptex-base.doc.r76790
	uptex-fonts.doc.r74119
	wadalab.doc.r42428
	zxjafbfont.doc.r77677
	zxjatype.doc.r77677
"
TEXLIVE_MODULE_SRC_CONTENTS="
	ascmac.source.r53411
	babel-japanese.source.r57733
	bxjscls.source.r75447
	japanese-otf.source.r77677
	jlreq.source.r77677
	jsclasses.source.r77677
	luatexja.source.r78116
	mendex-doc.source.r75172
	morisawa.source.r77677
	platex.source.r77677
	ptex-fontmaps.source.r65953
	pxrubrica.source.r66298
	uplatex.source.r77677
"

# Transitional pin: TL_PV anchors the eclass-derived texlive-core
# dep to TL2024 until app-text/texlive-core-2025 lands here.
TL_PV=2024

inherit texlive-module

DESCRIPTION="TeXLive Japanese"

LICENSE="BSD BSD-2 GPL-1+ GPL-2 GPL-3 LPPL-1.3 LPPL-1.3c MIT OFL-1.1 TeX TeX-other-free public-domain"
SLOT="0"
KEYWORDS="~amd64"
COMMON_DEPEND="
	>=dev-texlive/texlive-langcjk-2024
"
RDEPEND="
	${COMMON_DEPEND}
	dev-lang/ruby
"
DEPEND="
	${COMMON_DEPEND}
	>=dev-texlive/texlive-latex-2024
"

TEXLIVE_MODULE_BINSCRIPTS="
	texmf-dist/scripts/convbkmk/convbkmk.rb
	texmf-dist/scripts/ptex-fontmaps/kanji-config-updmap-sys.sh
	texmf-dist/scripts/ptex-fontmaps/kanji-config-updmap-user.sh
	texmf-dist/scripts/ptex-fontmaps/kanji-config-updmap.pl
	texmf-dist/scripts/ptex-fontmaps/kanji-fontmap-creator.pl
	texmf-dist/scripts/ptex2pdf/ptex2pdf.lua
"

src_prepare() {
	default

	# e(u)ptex are installed by texlive-core[cjk]
	sed -i '/AddFormat name=eptex /d' tlpkg/tlpobj/ptex.tlpobj || die
	sed -i '/AddFormat name=euptex /d' tlpkg/tlpobj/uptex.tlpobj || die

	if use doc; then
		# ptekf.1 is installed by dev-libs/ptexenc
		rm texmf-dist/doc/man/man1/ptekf.1 || die
	fi
}
