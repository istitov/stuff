# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

LANGS="ru uk"
inherit qt4-r2 versionator

PREMY_PV=$(replace_all_version_separators '-')
MY_PV=$(replace_version_separator 1 '.' $PREMY_PV)

SRC_URI="https://launchpad.net/~yuberion/+archive/pulsar/+files/${PN}_${MY_PV}.tar.gz"
DESCRIPTION="Cloud audio player (i.e. vk.com)"
HOMEPAGE="https://launchpad.net/~yuberion/+archive/pulsar"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="x11-libs/qt-core:4
	x11-libs/qt-dbus:4
	x11-libs/qt-gui:4
	x11-libs/qt-xmlpatterns:4
	x11-libs/qt-script:4
	media-libs/qt-gstreamer
	media-libs/gst-plugins-ugly"
RDEPEND=${DEPEND}

IUSE=""

S="${WORKDIR}/${PN}"

src_prepare() {
	epatch "${FILESDIR}/fdo_desktop.patch"
}

src_install() {
	qt4-r2_src_install
	insinto /usr/share/${PN}/translations
	for l in ${LANGS}; do
		if use linguas_${l}; then
			doins src/translations/${PN}_${l}.qm
		fi
	done
}
