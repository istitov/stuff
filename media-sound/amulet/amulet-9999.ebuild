# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cmake git-r3

DESCRIPTION="Elegant and simple audio converter"
HOMEPAGE="https://github.com/aka-mccloud/amulet.git"
EGIT_REPO_URI="https://github.com/aka-mccloud/amulet.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="flac mp3"

BDEPEND="virtual/pkgconfig"
RDEPEND="
	flac? ( media-libs/flac )
	mp3? ( media-sound/lame )"
DEPEND="
	media-libs/taglib
	dev-qt/qtgui:5
	dev-qt/qtcore:5
	dev-qt/qtwidgets"
