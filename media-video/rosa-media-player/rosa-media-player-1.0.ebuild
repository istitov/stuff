# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils qt4-r2 multilib

DESCRIPTION="ROSA Media Player"
HOMEPAGE="http://www.rosalab.ru/"
SRC_URI="http://stuff.tazhate.com/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
LANGS="ar bg ca cs de el en_GB es_LA es et eu fi fr gl hu it ja ka ko ku lt mk nl pl pt_PT pt pt_BR ro ru sk sl sr sv tr uk vi zh_CN zh_TW"
for lang in ${LANGS}; do
	IUSE+=" linguas_${lang}"
done

RDEPEND="media-video/mplayer"
DEPEND="${RDEPEND}
	dev-libs/glib
	dev-qt/qtcore:4
	dev-qt/qtgui:4"

S="${WORKDIR}/${PN}"

src_compile() {
	sed -i '1i#define OF(x) x' \
	  src/findsubtitles/quazip/ioapi.{c,h} \
	  src/findsubtitles/quazip/{zip,unzip}.h || die

	emake PREFIX=/usr || die
}

src_install() {
	for lang in ${LANGS};do
	  for x in ${lang};do
		if ! use linguas_${x}; then
		  rm -f "$(find src/translations -type f -name "rosamp_${x}*.qm")"
		  rm -rf docs/${x}
		fi
	  done
	done

	emake PREFIX=/usr DESTDIR="${D}" install || die
}
