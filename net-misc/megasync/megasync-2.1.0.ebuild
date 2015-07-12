# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils multilib

DESCRIPTION="The official QT-Based mega.co.nz client for sync your MEGA account"
HOMEPAGE="http://mega.co.nz"

URL_64="https://mega.co.nz/linux/MEGAsync/Debian_8.0/amd64/${PN/-bin/}_${PV}_amd64.deb"
URL_32="https://mega.co.nz/linux/MEGAsync/Debian_8.0/i386/${PN/-bin/}_${PV}_i386.deb"

SRC_URI="
	amd64? ( ${URL_64} )
	x86? ( ${URL_32} )
"

LICENSE="MEGA"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="mirror"

DEPEND="
	sys-devel/binutils
	app-arch/tar
"

RDEPEND="
	dev-qt/qtdbus:4
	dev-libs/openssl
	 media-libs/libpng
	 net-dns/c-ares
	 dev-libs/crypto++"

S="${WORKDIR}"

src_unpack() {
        unpack "$A"
        unpack ./data.tar.xz
        cd ./usr
}

src_install() {
	exeinto /usr/bin
    doexe usr/bin/megasync
    domenu usr/share/applications/megasync.desktop
    doicon -s 16 usr/share/icons/hicolor/16x16/apps/mega.png
    doicon -s 32 usr/share/icons/hicolor/32x32/apps/mega.png
    doicon -s 48 usr/share/icons/hicolor/48x48/apps/mega.png
    doicon -s 128 usr/share/icons/hicolor/128x128/apps/mega.png
    doicon -s 256 usr/share/icons/hicolor/256x256/apps/mega.png
}
