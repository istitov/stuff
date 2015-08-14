# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

MYSPELL_DICT=(
	"ky_KG.aff"
	"ky_KG.dic"
)

inherit eutils myspell-r2

DESCRIPTION="Kirghiz dictionaries for myspell/hunspell"
HOMEPAGE="http://borel.slu.edu/crubadan/"
FILENAME=aspell6-ky-0.01-0
SRC_URI="mirror://gnu/aspell/dict/ky/${FILENAME}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-text/hunspell"

RDEPEND="${DEPEND}
	app-text/aspell"

S="${WORKDIR}/${FILENAME}"

src_configure() {
	./configure
}

src_compile() {
	emake
	export LANG=ky_KG.utf8
	preunzip -d *.cwl
	cat *.wl > kirghiz.wordlist
	wordlist2hunspell kirghiz.wordlist ky_KG
	cp -p ky_affix.dat ky_KG.aff
}
