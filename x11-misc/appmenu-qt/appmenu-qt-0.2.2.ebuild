# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit cmake-utils

DESCRIPTION="Application menu module for Qt "
HOMEPAGE="https://launchpad.net/appmenu-qt"
SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${PN}-${PV}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

CDEPEND=">=x11-libs/qt-gui-4.7.4 [appmenu]"
DEPEND=">=dev-libs/libdbusmenu-qt-0.9.0"
RDEPEND="${DEPEND}"
