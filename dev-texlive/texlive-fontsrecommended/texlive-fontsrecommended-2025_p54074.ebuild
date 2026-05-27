# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TEXLIVE_MODULE_CONTENTS="
	collection-fontsrecommended.r54074
	avantgar.r77161
	bookman.r77161
	charter.r15878
	cm-super.r15878
	cmextra.r57866
	courier.r77161
	euro.r22191
	euro-ce.r25714
	eurosym.r78116
	fpl.r54512
	helvetic.r77161
	lm.r77677
	lm-math.r67718
	manfnt-font.r45777
	marvosym.r77677
	mathpazo.r77677
	mflogo-font.r54512
	ncntrsbk.r77161
	palatino.r77161
	pxfonts.r77677
	rsfs.r15878
	symbol.r77161
	tex-gyre.r68624
	tex-gyre-math.r41264
	times.r77161
	tipa.r77677
	txfonts.r77677
	utopia.r77677
	wasy.r53533
	wasy-type1.r53534
	wasysym.r77677
	zapfchan.r77161
	zapfding.r77161
"
TEXLIVE_MODULE_DOC_CONTENTS="
	charter.doc.r15878
	cm-super.doc.r15878
	euro.doc.r22191
	euro-ce.doc.r25714
	eurosym.doc.r78116
	fpl.doc.r54512
	lm.doc.r77677
	lm-math.doc.r67718
	marvosym.doc.r77677
	mathpazo.doc.r77677
	mflogo-font.doc.r54512
	pxfonts.doc.r77677
	rsfs.doc.r15878
	tex-gyre.doc.r68624
	tex-gyre-math.doc.r41264
	tipa.doc.r77677
	txfonts.doc.r77677
	utopia.doc.r77677
	wasy.doc.r53533
	wasy-type1.doc.r53534
	wasysym.doc.r77677
"
TEXLIVE_MODULE_SRC_CONTENTS="
	euro.source.r22191
	fpl.source.r54512
	marvosym.source.r77677
	mathpazo.source.r77677
	tex-gyre.source.r68624
	tex-gyre-math.source.r41264
	wasysym.source.r77677
"

# Transitional pin: TL_PV anchors the eclass-derived texlive-core
# dep to TL2024 until app-text/texlive-core-2025 lands here.
TL_PV=2024

inherit texlive-module

DESCRIPTION="TeXLive Recommended fonts"

LICENSE="BSD GPL-1+ GPL-2 LPPL-1.3 LPPL-1.3c OFL-1.1 TeX TeX-other-free public-domain"
SLOT="0"
KEYWORDS="~amd64"
COMMON_DEPEND="
	>=dev-texlive/texlive-basic-2024
"
RDEPEND="
	${COMMON_DEPEND}
"
DEPEND="
	${COMMON_DEPEND}
"
