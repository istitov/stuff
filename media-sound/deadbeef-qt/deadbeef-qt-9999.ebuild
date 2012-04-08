# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit cmake-utils mercurial

DESCRIPTION="Qt interface plugin for Deadbeef player"
HOMEPAGE="https://bitbucket.org/tonn/deadbeef-qt/overview"
EHG_REPO_URI="https://bitbucket.org/tonn/deadbeef-qt/"

LICENSE="|| ( GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="media-sound/deadbeef
		x11-libs/qt-gui:4"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}/"
