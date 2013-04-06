# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

VIRTUALX_REQUIRED="test"
inherit kde4-base

DESCRIPTION="A Plasma widget to display menubar of application windows (compatible with kded-appmenu)"
HOMEPAGE="http://kde-apps.org/content/show.php/plasma-widget-kappmenubar?content=153884"
SRC_URI="http://kde-apps.org/CONTENT/content-files/153884-${P}.tar.gz"

LICENSE="GPL-3"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	kde-misc/libkappmenu
	!kde-misc/plasma-widget-menubar
	dev-libs/qjson"
