# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TEXLIVE_MODULE_CONTENTS="
	collection-langchinese.r77432
	arphic.r15878
	arphic-ttf.r42675
	cns.r45677
	ctex.r77677
	exam-zh.r76834
	fandol.r37889
	fduthesis.r67231
	hanzibox.r77677
	hyphen-chinese.r74115
	nanicolle.r56224
	njurepo.r50492
	pgfornament-han.r72640
	qyxf-book.r75712
	sjtutex.r78180
	suanpan-l3.r76924
	upzhkinsoku.r47354
	xpinyin.r77677
	xtuthesis.r47049
	zhlineskip.r51142
	zhlipsum.r54994
	zhmetrics.r22207
	zhmetrics-uptex.r40728
	zhnumber.r77677
	zhspacing.r41145
"
TEXLIVE_MODULE_DOC_CONTENTS="
	arphic.doc.r15878
	arphic-ttf.doc.r42675
	asymptote-by-example-zh-cn.doc.r15878
	asymptote-faq-zh-cn.doc.r15878
	asymptote-manual-zh-cn.doc.r15878
	cns.doc.r45677
	ctex.doc.r77677
	ctex-faq.doc.r15878
	exam-zh.doc.r76834
	fandol.doc.r37889
	fduthesis.doc.r67231
	hanzibox.doc.r77677
	impatient-cn.doc.r54080
	install-latex-guide-zh-cn.doc.r78232
	latex-notes-zh-cn.doc.r15878
	lshort-chinese.doc.r73160
	nanicolle.doc.r56224
	njurepo.doc.r50492
	pgfornament-han.doc.r72640
	qyxf-book.doc.r75712
	sjtutex.doc.r78180
	suanpan-l3.doc.r76924
	texlive-zh-cn.doc.r74098
	texproposal.doc.r43151
	tlmgr-intro-zh-cn.doc.r59100
	upzhkinsoku.doc.r47354
	xpinyin.doc.r77677
	xtuthesis.doc.r47049
	zhlineskip.doc.r51142
	zhlipsum.doc.r54994
	zhmetrics.doc.r22207
	zhmetrics-uptex.doc.r40728
	zhnumber.doc.r77677
	zhspacing.doc.r41145
"
TEXLIVE_MODULE_SRC_CONTENTS="
	ctex.source.r77677
	fduthesis.source.r67231
	hanzibox.source.r77677
	njurepo.source.r50492
	sjtutex.source.r78180
	xpinyin.source.r77677
	zhlipsum.source.r54994
	zhmetrics.source.r22207
	zhnumber.source.r77677
"

# Transitional pin: TL_PV anchors the eclass-derived texlive-core
# dep to TL2024 until app-text/texlive-core-2025 lands here.
TL_PV=2024

inherit texlive-module

DESCRIPTION="TeXLive Chinese"

LICENSE="FDL-1.1+ GPL-1+ GPL-3+ LGPL-2+ LPPL-1.3 LPPL-1.3c MIT TeX TeX-other-free public-domain"
SLOT="0"
KEYWORDS="~amd64"
COMMON_DEPEND="
	>=dev-texlive/texlive-langcjk-2024
"
RDEPEND="
	${COMMON_DEPEND}
"
DEPEND="
	${COMMON_DEPEND}
"

# Avoids collision with app-text/ttf2pk2
src_prepare() {
	default
	local i=texmf-dist/source/fonts/zhmetrics/ttfonts.map
	if [[ -f "${i}" ]]; then
		rm -f "${i}" || die
	fi
}
