# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/cloudcompare/cloudcompare-9999.ebuild,v 1.0 2014/02/26 20:00:00 brothermechanic Exp $

EAPI=5

inherit git-2 cmake-utils eutils

DESCRIPTION="3D point cloud processing software"
HOMEPAGE="http://www.danielgm.net/cc/"
EGIT_REPO_URI="https://github.com/archeos/cloudcompare-archeos.git"
EGIT_BRANCH="master"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="media-libs/glew
        dev-qt/qtcore
        dev-qt/qtopengl"

RDEPEND="${DEPEND}"

src_prepare() {
	"${WORKDIR}"/debian/patches/*.patch
}

src_configure() {
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}"
	-DCMAKE_INSTALL_PREFIX="${D}/usr"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	newicon ${S}/qCC/images/icon/cc_icon_64.png "${PN}".png
        make_desktop_entry CloudCompare
}


