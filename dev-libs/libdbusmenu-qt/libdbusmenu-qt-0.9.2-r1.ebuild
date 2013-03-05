# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libdbusmenu-qt/libdbusmenu-qt-0.8.2.ebuild,v 1.5 2011/06/26 01:56:02 ranger Exp $

EAPI=4

QT_DEPEND="4.6.3"
EGIT_REPO_URI="git://gitorious.org/dbusmenu/dbusmenu-qt.git"

[[ ${PV} == 9999* ]] && GIT_ECLASS="git-2"
inherit cmake-utils virtualx ${GIT_ECLASS}

DESCRIPTION="A library providing Qt implementation of DBusMenu specification"
HOMEPAGE="https://launchpad.net/libdbusmenu-qt/"
if [[ ${PV} == 9999* ]] ; then
	KEYWORDS=""
else
	#SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.bz2"
	# upstream has no permissions to use some kde written code so repack git
	# repo every time
	SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${PN}-${PV}.tar.bz2"
	KEYWORDS="amd64 ~arm ppc ~ppc64 x86 ~amd64-linux ~x86-linux"
fi

LICENSE="LGPL-2"
SLOT="0"
IUSE="debug doc"

RDEPEND="
	>=dev-qt/qtcore-${QT_DEPEND}:4
	>=dev-qt/qtgui-${QT_DEPEND}:4[dbus]
	>=dev-qt/qttest-${QT_DEPEND}:4
"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	test? (
		dev-libs/qjson
		>=dev-qt/qttest-${QT_DEPEND}:4
	)
"

DOCS=(NEWS README)

# Fix a bug that shows up in appmenu-firefox, see:
# https://bugs.launchpad.net/libdbusmenu-qt/+bug/1035755
PATCHES=( "${FILESDIR}/use-qx11info-apptime.patch" )

# tests fail due to missing conection to dbus
RESTRICT="test"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_build test TESTS)
		$(cmake-utils_use_with doc)
	)
	cmake-utils_src_configure
}

src_test() {
	local builddir=${CMAKE_BUILD_DIR}

	CMAKE_BUILD_DIR=${CMAKE_BUILD_DIR}/tests \
		VIRTUALX_COMMAND=cmake-utils_src_test virtualmake

	CMAKE_BUILD_DIR=${builddir}
}
