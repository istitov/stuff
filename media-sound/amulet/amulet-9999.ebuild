# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit qt4-r2 git-2

DESCRIPTION="Audio converter based on ffmpeg"
HOMEPAGE="http://gitorious.org/amulet"
EGIT_REPO_URI="git://gitorious.org/amulet/amulet.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="flac mp3"

DEPEND="flac? ( media-libs/flac )
	mp3? ( media-sound/lame )
	media-libs/taglib
	dev-qt/qtgui:4
	dev-qt/qtcore:4"

S="${WORKDIR}/${PN}"
