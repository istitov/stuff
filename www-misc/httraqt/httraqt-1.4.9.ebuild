# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit l10n cmake-utils # qt4-r2

MY_P=${PN}-${PV}

DESCRIPTION="Graphical user interface for HTTrack library, developed in C++ and based on Qt5"
HOMEPAGE="http://httraqt.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"
RESTRICT="primaryuri"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-qt/qtgui:5
	>=www-client/httrack-3.45.4"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"
CMAKE_VERBOSE="OFF"
