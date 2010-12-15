# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/grabvk/grabvk-0.0.4.ebuild,v 1 2010/12/06 00:13:35 megabaks Exp $

EAPI=3

inherit eutils

DESCRIPTION="music downloader from vkontakte.ru"
HOMEPAGE="http://grabvk.sourceforge.net/"
SRC_URI="http://sourceforge.net/projects/grabvk/files/grabvk_${PV}_version/grabvk_v${PV}_qtcreator_project.tar.gz"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc64 ~sparc ~x86"
IUSE=""

DEPEND_COMMON="
		x11-libs/qt-gui
		x11-libs/qt-core
	"
RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"
src_prepare() {
    epatch "${FILESDIR}"/GrabVK.patch
}

src_compile() {
	cd GrabVK
	qmake || die "qmake failed"
	emake || die "emake failed"
}

src_install() {
    insinto /usr/bin/
    cd GrabVK
    dobin GrabVK || die
    insinto /usr/share/applications
    doins grabvk.desktop
    insinto /usr/share/GrabVK/images/
    insinto /usr/share/icons/hicolor/16x16/apps/
    insinto /usr/share/icons/hicolor/32x32/apps/
    doins grabVK.png
}