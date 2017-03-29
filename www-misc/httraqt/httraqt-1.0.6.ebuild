# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit l10n qt4-r2 cmake-utils

MY_P=${PN}-${PV}

DESCRIPTION="Graphical user interface for HTTrack library, developed in C++ and based on Qt4"
HOMEPAGE="http://httraqt.sourceforge.net"

SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-qt/qtgui:4
	>=www-client/httrack-3.45.4"
RDEPEND="${DEPEND}"

CMAKE_VERBOSE="OFF"
