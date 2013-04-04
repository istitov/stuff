# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils qt4-r2 multilib

DESCRIPTION="Multimedia player that supports most of audio and video formats."
HOMEPAGE="http://www.rosalab.ru/"
MY_PN="ROSA_Media_Player"
SRC_URI="https://abf.rosalinux.ru/uxteam/${MY_PN}/archive/${MY_PN}-v${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
LANGS="ar_SY bg ca cs de el_GR en en_US es et eu fi fr gl hu it ja ka ko ku lt mk ms_MY nl pl pt pt_BR ro_RO ru_RU sk sl sl_SI sr sv tr uk_UA vi_VN zh_CN zh_TW"
for lang in ${LANGS}; do
	IUSE+=" linguas_${lang}"
done

RDEPEND="media-video/mplayer"
DEPEND="${RDEPEND}
	dev-libs/glib
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	dev-qt/qtmultimedia:4
	media-sound/wildmidi"

S="${WORKDIR}/${MY_PN}-v${PV}"

src_compile() {
	cd ${PN}
	sed -i '1i#define OF(x) x' \
		src/findsubtitles/quazip/ioapi.{c,h} \
		src/findsubtitles/quazip/{zip,unzip}.h || die
	emake PREFIX=/usr || die
}

src_install() {
	cd "${PN}"
	for lang in ${LANGS};do
	  for x in ${lang};do
		if ! use linguas_${x}; then
		  rm -f "$(find src/translations -type f -name "rosamp_${x}.qm")"
		  rm -rf docs/${x}
		fi
	  done
	done

	emake PREFIX=/usr DESTDIR="${D}" install || die
}
