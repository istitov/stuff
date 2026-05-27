# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TEXLIVE_MODULE_CONTENTS="
	collection-xetex.r71515
	arabxetex.r77677
	bidi-atbegshi.r62009
	bidicontour.r77677
	bidipagegrid.r77677
	bidipresentation.r35267
	bidishadowtext.r77677
	businesscard-qrcode.r76924
	cqubeamer.r54512
	fixlatvian.r21631
	font-change-xetex.r40404
	fontbook.r23608
	fontwrap.r15878
	interchar.r77677
	na-position.r55559
	philokalia.r45356
	ptext.r77677
	realscripts.r77677
	simple-resume-cv.r43057
	simple-thesis-dissertation.r43058
	tetragonos.r49732
	ucharclasses.r77677
	unicode-bidi.r77677
	unimath-plain-xetex.r72498
	unisugar.r22357
	xebaposter.r75290
	xechangebar.r77677
	xecolor.r77677
	xecyr.r77677
	xeindex.r77677
	xelatex-dev.r71363
	xesearch.r77677
	xespotcolor.r77677
	xetex.r73850
	xetex-itrans.r55475
	xetex-pstricks.r17055
	xetex-tibetan.r28847
	xetexconfig.r45845
	xetexfontinfo.r15878
	xetexko.r77677
	xevlna.r77677
	zbmath-review-template.r59693
"
TEXLIVE_MODULE_DOC_CONTENTS="
	arabxetex.doc.r77677
	bidi-atbegshi.doc.r62009
	bidicontour.doc.r77677
	bidipagegrid.doc.r77677
	bidipresentation.doc.r35267
	bidishadowtext.doc.r77677
	businesscard-qrcode.doc.r76924
	cqubeamer.doc.r54512
	fixlatvian.doc.r21631
	font-change-xetex.doc.r40404
	fontbook.doc.r23608
	fontwrap.doc.r15878
	interchar.doc.r77677
	na-position.doc.r55559
	philokalia.doc.r45356
	ptext.doc.r77677
	realscripts.doc.r77677
	simple-resume-cv.doc.r43057
	simple-thesis-dissertation.doc.r43058
	tetragonos.doc.r49732
	ucharclasses.doc.r77677
	unicode-bidi.doc.r77677
	unimath-plain-xetex.doc.r72498
	unisugar.doc.r22357
	xebaposter.doc.r75290
	xechangebar.doc.r77677
	xecolor.doc.r77677
	xecyr.doc.r77677
	xeindex.doc.r77677
	xesearch.doc.r77677
	xespotcolor.doc.r77677
	xetex.doc.r73850
	xetex-itrans.doc.r55475
	xetex-pstricks.doc.r17055
	xetex-tibetan.doc.r28847
	xetexfontinfo.doc.r15878
	xetexko.doc.r77677
	xevlna.doc.r77677
	zbmath-review-template.doc.r59693
"
TEXLIVE_MODULE_SRC_CONTENTS="
	arabxetex.source.r77677
	fixlatvian.source.r21631
	fontbook.source.r23608
	philokalia.source.r45356
	realscripts.source.r77677
	xespotcolor.source.r77677
"

inherit font texlive-module

DESCRIPTION="TeXLive XeTeX and packages"

LICENSE="Apache-2.0 CC-BY-4.0 CC-BY-SA-4.0 GPL-1+ GPL-3 LGPL-2+ LPPL-1.2 LPPL-1.3 LPPL-1.3c MIT TeX-other-free public-domain"
SLOT="0"
KEYWORDS="~amd64"
COMMON_DEPEND="
	>=app-text/texlive-core-2024[xetex]
	>=dev-texlive/texlive-basic-2024
	>=dev-texlive/texlive-latex-2024
"
RDEPEND="
	${COMMON_DEPEND}
"
DEPEND="
	${COMMON_DEPEND}
	!!<dev-texlive/texlive-latexextra-2023
"

TEXLIVE_MODULE_BINSCRIPTS="
	texmf-dist/scripts/texlive-extra/xelatex-unsafe.sh
	texmf-dist/scripts/texlive-extra/xetex-unsafe.sh
"

FONT_CONF=( "${FILESDIR}"/09-texlive.conf )

src_install() {
	texlive-module_src_install
	font_fontconfig
}

pkg_postinst() {
	texlive-module_pkg_postinst
	font_pkg_postinst
}

pkg_postrm() {
	texlive-module_pkg_postrm
	font_pkg_postrm
}
