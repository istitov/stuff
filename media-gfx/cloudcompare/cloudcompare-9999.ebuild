# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/cloudcompare/cloudcompare-9999.ebuild,v 0.1 2013/10/29 20:00:00 brothermechanic Exp $

EAPI=5

inherit git-2 cmake-utils eutils

DESCRIPTION="3D point cloud processing software"
HOMEPAGE="http://www.danielgm.net/cc/"
EGIT_REPO_URI="https://github.com/cloudcompare/trunk.git"
EGIT_BRANCH="master"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pcl"

DEPEND="media-libs/glew
        dev-qt/qtcore
        dev-qt/qtopengl
	pcl? ( sci-libs/pcl )"

RDEPEND="${DEPEND}"

src_prepare() {
        epatch "${FILESDIR}"/01-Doc-must-live-in-a-good-dir.patch
	epatch "${FILESDIR}"/02-Dynamic-directories.patch
	epatch "${FILESDIR}"/03-Use-Debian-libGLEW.patch
	epatch "${FILESDIR}"/04-Fix-local-decimal-separator.patch
	epatch "${FILESDIR}"/05-Use-package-directory-for-libs.patch
	epatch "${FILESDIR}"/06-Remove-StyleSheet-in-ccViewer.patch
	epatch "${FILESDIR}"/07-DXF_support.patch
}

src_configure() {
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}"
	-DCMAKE_INSTALL_PREFIX="${D}/usr"
	if use pcl; then
	mycmakeargs="${mycmakeargs} -DINSTALL_QPCL_PLUGIN=ON"
	fi
	cmake-utils_src_configure
}
