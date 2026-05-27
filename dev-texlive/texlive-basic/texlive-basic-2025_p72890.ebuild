# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TEXLIVE_MODULE_CONTENTS="
	collection-basic.r72890
	amsfonts.r77677
	bibtex.r77677
	cm.r57963
	colorprofiles.r49086
	ec.r25033
	enctex.r34957
	etex.r73850
	etex-pkg.r77677
	graphics-def.r76719
	hyph-utf8.r74823
	hyphenex.r57387
	ifplatform.r77677
	iftex.r77677
	knuth-lib.r57963
	knuth-local.r57963
	lua-alt-getopt.r56414
	luahbtex.r73848
	luajittex.r73848
	luatex.r76924
	metafont.r73848
	mflogo.r77677
	mfware.r77677
	modes.r77365
	pdftex.r74113
	plain.r75712
	tex.r73848
	tex-ini-files.r73863
	texlive-msg-translations.r77642
	tlshell.r75412
	unicode-data.r76413
"
TEXLIVE_MODULE_DOC_CONTENTS="
	amsfonts.doc.r77677
	bibtex.doc.r77677
	cm.doc.r57963
	colorprofiles.doc.r49086
	ec.doc.r25033
	enctex.doc.r34957
	etex.doc.r73850
	etex-pkg.doc.r77677
	graphics-def.doc.r76719
	hyph-utf8.doc.r74823
	ifplatform.doc.r77677
	iftex.doc.r77677
	lua-alt-getopt.doc.r56414
	luahbtex.doc.r73848
	luajittex.doc.r73848
	luatex.doc.r76924
	metafont.doc.r73848
	mflogo.doc.r77677
	mfware.doc.r77677
	modes.doc.r77365
	pdftex.doc.r74113
	tex.doc.r73848
	tex-ini-files.doc.r73863
	texlive-common.doc.r75685
	texlive-en.doc.r74120
	tlshell.doc.r75412
	unicode-data.doc.r76413
"
TEXLIVE_MODULE_SRC_CONTENTS="
	amsfonts.source.r77677
	hyph-utf8.source.r74823
	hyphenex.source.r57387
	ifplatform.source.r77677
	mflogo.source.r77677
"

TEXLIVE_MODULE_OPTIONAL_ENGINE="luajittex"

inherit texlive-module

DESCRIPTION="TeXLive Essential programs and files"

LICENSE="GPL-1+ GPL-2+ LPPL-1.3 LPPL-1.3c MIT OFL-1.1 TeX TeX-other-free public-domain"
SLOT="0"
KEYWORDS="~amd64"

COMMON_DEPEND="
	>=app-text/texlive-core-2024[luajittex?]
"
RDEPEND="
	${COMMON_DEPEND}
	>=app-text/dvipsk-2024.03.11_p70015
"
DEPEND="
	${COMMON_DEPEND}
"

TEXLIVE_MODULE_BINSCRIPTS="
	texmf-dist/scripts/simpdftex/simpdftex
	texmf-dist/scripts/tlshell/tlshell.tcl
"

src_prepare() {
	default
	if ! use luajittex; then
		rm -rf texmf-dist/{,scripts,doc}/luajittex
		rm tlpkg/tlpobj/luajittex.* || die
	fi
}
