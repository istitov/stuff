# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

VIRTUALX_REQUIRED="test"
inherit kde4-base

MY_PN="kwinbuttonapplet-improved"

DESCRIPTION="KWinButton applet"
HOMEPAGE="http://kde-look.org/content/show.php/KWin+Button+applet+improved?content=143971"
SRC_URI="http://kde-look.org/CONTENT/content-files/143971-${MY_PN}-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE="debug test"

DEPEND="kde-base/libkworkspace:4
kde-base/libtaskmanager:4"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}"
