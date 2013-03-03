# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit cmake-utils

DESCRIPTION="Application menu module for Qt "
HOMEPAGE="https://launchpad.net/appmenu-qt"
SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-qt/qtgui-4.8
		>=dev-libs/libdbusmenu-qt-0.9.0"
RDEPEND="${DEPEND}"

DOCS=( NEWS README )