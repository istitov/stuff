# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit plocale cmake

MY_P=${PN}-${PV}

DESCRIPTION="Graphical user interface for HTTrack library, developed in C++ and based on Qt"
HOMEPAGE="http://httraqt.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-qt/qtgui:6
	>=www-client/httrack-3.45.4"
RDEPEND="${DEPEND}"

#S="${WORKDIR}/${PN}"
CMAKE_VERBOSE="OFF"
