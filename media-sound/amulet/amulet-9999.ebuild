# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Elegant audio converter based on ffmpeg"
HOMEPAGE="https://github.com/aka-mccloud/amulet"
EGIT_REPO_URI="https://github.com/aka-mccloud/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
IUSE="+flac +mp3"

# Both flags default on because AmuletPlugins/CMakeLists.txt builds
# codec_flac and codec_lame unconditionally and we do not patch that, so the
# plugins are installed either way. They link only Qt and amulet_core and
# reach the codecs by QProcess-ing the flac and lame binaries, so with both
# flags off the app installs and starts but every conversion fails. The flags
# select which codec tools come along, not which plugins get built.
# verified 2026-07-27
RDEPEND="
	dev-qt/qtbase:6[gui,widgets]
	media-libs/taglib
	flac? ( media-libs/flac )
	mp3? ( media-sound/lame )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/amulet-9999-qt6.patch
)
