# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit cmake-utils git-2

DESCRIPTION="Qt interface plugin for Deadbeef player"
HOMEPAGE="https://github.com/redpunk231/deadbeef-qt"
EGIT_REPO_URI="git://github.com/redpunk231/deadbeef-qt.git"

LICENSE="|| ( GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="media-sound/deadbeef
		dev-qt/qtgui:4"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}/"
