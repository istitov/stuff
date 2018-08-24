# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit eutils qmake-utils multilib

DESCRIPTION="ROSA Media Player"
HOMEPAGE="http://www.rosalab.ru/"
SRC_URI="http://stuff.tazhate.com/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# Workaround: please keep it sorted syncronous
L10Ns="ar bg ca cs de el en-GB es-419 es et eu fi fr gl hu it ja ka ko ku lt mk nl pl pt-PT pt pt-BR ro ru sk sl sr sv tr uk vi zh-CN zh-TW"
LANGS="ar bg ca cs de el en_GB es_LA es et eu fi fr gl hu it ja ka ko ku lt mk nl pl pt_PT pt pt_BR ro ru sk sl sr sv tr uk vi zh_CN zh_TW"
for lang in ${L10Ns}; do
	IUSE+=" l10n_${lang}"
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
			if ! use l10n_${x}; then
				rm -f "$(find src/translations -type f -name "rosamp_${x}*.qm")"
				rm -rf docs/${x}
			fi
		done
	done

	emake PREFIX=/usr DESTDIR="${D}" install || die
}
