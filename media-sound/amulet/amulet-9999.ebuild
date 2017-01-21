# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"

inherit qt4-r2 git-r3

DESCRIPTION="Audio converter based on flac, lame..."
HOMEPAGE="http://gitorious.org/amulet"
EGIT_REPO_URI="https://gitorious.org/amulet/amulet.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="flac mp3"

DEPEND="flac? ( media-libs/flac )
	mp3? ( media-sound/lame )
	media-libs/taglib
	dev-qt/qtgui:4
	dev-qt/qtcore:4"

S="${WORKDIR}/${PN}"
