# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TEXLIVE_MODULE_CONTENTS="
	collection-langgreek.r65038
	babel-greek.r78116
	begingreek.r63255
	betababel.r15878
	cbfonts.r54080
	cbfonts-fd.r54080
	gfsbaskerville.r77677
	gfsporson.r77677
	greek-fontenc.r77677
	greek-inputenc.r66634
	greekdates.r75878
	greektex.r28327
	greektonoi.r39419
	hyphen-ancientgreek.r74823
	hyphen-greek.r73410
	ibycus-babel.r15878
	ibygrk.r15878
	kerkis.r56271
	levy.r76924
	lgreek.r21818
	lgrmath.r65038
	mkgrkindex.r26313
	talos.r61820
	teubner.r68074
	xgreek.r77677
	yannisgr.r22613
"
TEXLIVE_MODULE_DOC_CONTENTS="
	babel-greek.doc.r78116
	begingreek.doc.r63255
	betababel.doc.r15878
	cbfonts.doc.r54080
	cbfonts-fd.doc.r54080
	gfsbaskerville.doc.r77677
	gfsporson.doc.r77677
	greek-fontenc.doc.r77677
	greek-inputenc.doc.r66634
	greekdates.doc.r75878
	greektex.doc.r28327
	greektonoi.doc.r39419
	hyphen-greek.doc.r73410
	ibycus-babel.doc.r15878
	ibygrk.doc.r15878
	kerkis.doc.r56271
	levy.doc.r76924
	lgreek.doc.r21818
	lgrmath.doc.r65038
	mkgrkindex.doc.r26313
	talos.doc.r61820
	teubner.doc.r68074
	xgreek.doc.r77677
	yannisgr.doc.r22613
"
TEXLIVE_MODULE_SRC_CONTENTS="
	babel-greek.source.r78116
	begingreek.source.r63255
	cbfonts-fd.source.r54080
	greekdates.source.r75878
	ibycus-babel.source.r15878
	lgrmath.source.r65038
	teubner.source.r68074
	xgreek.source.r77677
"

# Transitional pin: TL_PV anchors the eclass-derived texlive-core
# dep to TL2024 until app-text/texlive-core-2025 lands here.
TL_PV=2024

inherit texlive-module

DESCRIPTION="TeXLive Greek"

LICENSE="BSD-2 GPL-1+ GPL-2 LGPL-3 LPPL-1.3 LPPL-1.3c TeX-other-free public-domain"
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

TEXLIVE_MODULE_BINSCRIPTS="
	texmf-dist/scripts/mkgrkindex/mkgrkindex
"
