# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

VIRTUALX_REQUIRED="test"
inherit kde4-base

DESCRIPTION="To display your application menubar at top screen, using a title bar button..."
HOMEPAGE="http://kde-apps.org/content/show.php/kded-appmenu?content=153882"
SRC_URI="http://kde-apps.org/CONTENT/content-files/153882-${P}.tar.gz"

LICENSE="GPL-3"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE="gtk2 gtk3"

DEPEND="
	x11-misc/appmenu-qt
	<kde-base/systemsettings-4.10[appmenu]
	gtk2? ( x11-misc/appmenu-gtk[gtk2] )
	gtk3? ( x11-misc/appmenu-gtk[gtk3] )"
RDEPEND="
	!kde-misc/plasma-widget-menubar
	${DEPEND}"
