# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/kde-partition-manager/kde-partition-manager-1.0.3.ebuild,v 1 2010/12/26 05:32:35 megabaks Exp $

EAPI=3

inherit eutils

DESCRIPTION="KDE Partition Editor"
HOMEPAGE="http://kde-apps.org/content/show.php/KDE+Partition+Manager?content=89595"
SRC_URI="http://kde-apps.org/CONTENT/content-files/89595-partitionmanager-1.0.3.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc64 ~sparc ~x86"
IUSE=""

DEPEND_COMMON="
		>=kde-base/kdelibs-4.1.0
		>=x11-libs/qt-gui-4.7.0
		>=x11-libs/qt-core-4.7.0
		sys-block/parted
		sys-apps/util-linux
	"
RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"
S="${WORKDIR}/partitionmanager-${PV}"

src_compile() {
	cmake ${S} 
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
