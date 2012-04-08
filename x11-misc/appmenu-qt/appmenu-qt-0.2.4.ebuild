# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit cmake-utils

DESCRIPTION="Application menu module for Qt "
HOMEPAGE="https://launchpad.net/appmenu-qt"
SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${PN}-${PV}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="-alpha ~amd64 -ppc64 -sparc ~x86"
IUSE=""

DEPEND="|| ( <x11-libs/qt-gui-4.8[appmenu] >=x11-libs/qt-gui-4.8 )
		>=dev-libs/libdbusmenu-qt-0.9.0"
RDEPEND="${DEPEND}"
