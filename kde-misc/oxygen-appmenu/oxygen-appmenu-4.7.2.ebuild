# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

VIRTUALX_REQUIRED="test"
inherit kde4-base

DESCRIPTION="Oxygen-appmenu is an oxygen style for kwin displaying application menu in titlebar"
HOMEPAGE="http://kde-look.org/content/show.php?content=141254"
SRC_URI="http://kde-look.org/CONTENT/content-files/141254-${PN}-${PV}.tgz"

LICENSE="GPL-3"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="kde-base/libkworkspace:4
		kde-base/libtaskmanager:4
		kde-base/kwin:4
		x11-misc/appmenu-qt"
RDEPEND="${DEPEND}"

