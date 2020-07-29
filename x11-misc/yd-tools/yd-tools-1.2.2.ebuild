# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit unpacker

DESCRIPTION="Panel indicator for YandexDisk CLI client for Linux"
HOMEPAGE="https://github.com/slytomcat/yandex-disk-indicator"
SRC_URI="https://launchpad.net/~slytomcat/+archive/ubuntu/ppa/+files/yd-tools_1.2.2_all.deb"
RESTRICT="primaryuri"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
#Masked as far as gnome-python has been removed
IUSE=""

RDEPEND="net-misc/yandex-disk
	x11-misc/xclip
	x11-libs/libnotify
	x11-libs/gdk-pixbuf
	dev-python/gconf-python
	dev-libs/libappindicator:=
	dev-python/pygobject:3
	dev-python/pyinotify"
DEPEND="${RDEPEND}"

#S="${WORKDIR}"/CLD-Icons

src_unpack() {
	mkdir -p "${WORKDIR}/${P}"
	cd "${WORKDIR}/${P}"
	unpack_deb ${A}
}

src_install() {
	cp -Rp * "${D}"
}
