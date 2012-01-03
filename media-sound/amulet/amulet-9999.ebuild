# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit qt4-r2 git-2

DESCRIPTION="Audio converter based on ffmpeg"
HOMEPAGE="http://gitorious.org/amulet"
EGIT_REPO_URI="git://gitorious.org/amulet/amulet.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="mp3"
DEPEND="|| ( mp3? ( virtual/ffmpeg[mp3] ) virtual/ffmpeg )
		x11-libs/qt-gui:4
		x11-libs/qt-core:4"
S="${WORKDIR}/${PN}"

