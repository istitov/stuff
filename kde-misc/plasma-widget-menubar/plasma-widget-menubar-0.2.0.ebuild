# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

VIRTUALX_REQUIRED="test"
inherit kde4-base

DESCRIPTION="A Plasma widget to display menubar of application windows"
HOMEPAGE="https://launchpad.net/plasma-widget-menubar"
SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE="debug test gtk qt4"

DEPEND="
	gtk? ( x11-misc/appmenu-gtk )
	qt4? ( x11-misc/appmenu-qt )
	>=dev-libs/libdbusmenu-qt-0.9.0
	>=dev-libs/qjson-0.7.1
	>=kde-base/plasma-workspace-4.10
"
RDEPEND="${DEPEND}
	!kde-misc/plasma-indicatordisplay
	!kde-misc/kded-appmenu
"
