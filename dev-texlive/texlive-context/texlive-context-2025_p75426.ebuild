# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TEXLIVE_MODULE_CONTENTS="
	collection-context.r75426
	context.r78011
	context-calendar-examples.r66947
	context-chat.r72010
	context-collating-marks.r68696
	context-cyrillicnumbers.r47085
	context-filter.r62070
	context-gnuplot.r75301
	context-handlecsv.r76721
	context-legacy.r78011
	context-letter.r77850
	context-mathsets.r47085
	context-pocketdiary.r73164
	context-simpleslides.r67070
	context-squares.r77884
	context-sudoku.r77885
	context-transliterator.r61127
	context-typescripts.r76524
	context-vim.r62071
	context-visualcounter.r47085
	jmn.r45751
"
# Removed in target tlpdb: context-companion-fonts, context-texlive
TEXLIVE_MODULE_DOC_CONTENTS="
	context.doc.r78011
	context-calendar-examples.doc.r66947
	context-chat.doc.r72010
	context-collating-marks.doc.r68696
	context-cyrillicnumbers.doc.r47085
	context-filter.doc.r62070
	context-gnuplot.doc.r75301
	context-handlecsv.doc.r76721
	context-legacy.doc.r78011
	context-letter.doc.r77850
	context-mathsets.doc.r47085
	context-notes-zh-cn.doc.r76286
	context-pocketdiary.doc.r73164
	context-simpleslides.doc.r67070
	context-squares.doc.r77884
	context-sudoku.doc.r77885
	context-transliterator.doc.r61127
	context-typescripts.doc.r76524
	context-vim.doc.r62071
	context-visualcounter.doc.r47085
"
# Removed in target tlpdb: context-companion-fonts.doc, context-texlive.doc
TEXLIVE_MODULE_SRC_CONTENTS="
	context-visualcounter.source.r47085
"

# Transitional pin: TL_PV anchors the eclass-derived texlive-core
# dep to TL2024 until app-text/texlive-core-2025 lands here.
TL_PV=2024

inherit greadme texlive-module

DESCRIPTION="TeXLive ConTeXt and packages"

LICENSE="BSD BSD-2 GPL-1+ GPL-2 GPL-3 MIT TeX-other-free public-domain"
SLOT="0"
KEYWORDS="~amd64"
COMMON_DEPEND="
	>=dev-texlive/texlive-basic-2024
"
RDEPEND="
	${COMMON_DEPEND}
	dev-lang/ruby
"
DEPEND="
	${COMMON_DEPEND}
	>=app-text/texlive-core-2024[xetex]
"

TEXLIVE_MODULE_BINSCRIPTS="
	texmf-dist/scripts/context-texlive/stubs-mkiv/unix/contextjit
	texmf-dist/scripts/context-texlive/stubs-mkiv/unix/luatools
	texmf-dist/scripts/context-texlive/stubs-mkiv/unix/mtxrunjit

	texmf-dist/scripts/context-texlive/stubs/unix/texexec
	texmf-dist/scripts/context-texlive/stubs/unix/texmfstart
"

src_prepare() {
	default
	# No need to install these .exe
	rm -r texmf-dist/scripts/context-texlive/stubs/win64 || die
}

src_install() {
	texlive-module_src_install

	local mtxrun=/usr/share/texmf-dist/scripts/context/lua/mtxrun.lua
	fperms 755 "${mtxrun}"
	newbin - mtxrun <<-EOF
	#!/bin/sh
	export TEXMF_DIST="${EPREFIX}/usr/share/texmf-dist"
	exec ${mtxrun} "\$@"
EOF

	newbin - context <<-EOF
	#!/bin/sh
	exec mtxrun --script context "\$@"
EOF

	greadme_stdin <<-EOF
	For using ConTeXt mkII simply use 'texexec' to generate your documents.
	If you plan to use mkIV and its 'context' command to generate your documents,
	you have to run 'mtxrun --generate' as normal user before first use.

	More information and advanced options on:
	http://wiki.contextgarden.net/TeX_Live_2011
EOF
}

pkg_postinst() {
	texlive-module_pkg_postinst
	greadme_pkg_postinst
}
