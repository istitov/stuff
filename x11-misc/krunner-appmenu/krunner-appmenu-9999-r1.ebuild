# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: x11-misc/krunner-appmenu-9999.ebuild,v 1 2012/08/31 01:55:00 megabaks Exp $

EAPI=4

inherit cmake-utils git-2

DESCRIPTION="A krunner plugin that searches the appmenu"
HOMEPAGE="http://kde.org/"
EGIT_REPO_URI="git://anongit.kde.org/appmenu-runner"
EGIT_PROJECT="appmenu"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="
	dev-libs/libdbusmenu-qt
	x11-misc/appmenu-qt
	kde-base/kdelibs"

RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"

S="${WORKDIR}/${PN}"

src_configure() {
	local mycmakeargs=(
	  -DCMAKE_BUILD_TYPE=Release
	  -DCMAKE_INSTALL_PREFIX=`kde4-config --prefix`
	  )
	cmake-utils_src_configure
}
