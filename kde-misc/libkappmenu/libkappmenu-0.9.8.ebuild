# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

VIRTUALX_REQUIRED="test"
inherit kde4-base

DESCRIPTION="Lib interface for kded-appmenu dbus menu registrar"
HOMEPAGE="http://kde-apps.org/content/show.php/libkappmenu?content=153883"
SRC_URI="http://kde-apps.org/CONTENT/content-files/153883-${P}.tar.gz"

LICENSE="GPL-3"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="
	kde-misc/kded-appmenu
	!kde-misc/plasma-widget-menubar
	${DEPEND}"
