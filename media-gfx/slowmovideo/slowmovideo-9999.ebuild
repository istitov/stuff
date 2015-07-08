# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/slowmovideo/slowmovideo-9999.ebuild,v 1.2 2013/03/04 16:12:45 brothermechanic Exp $

EAPI=5

CMAKE_IN_SOURCE_BUILD="1"
EGIT_REPO_URI="https://github.com/Granjow/slowmoVideo.git"

inherit cmake-utils eutils git-2

DESCRIPTION="Create slow-motion videos from your footage"
HOMEPAGE="http://slowmovideo.granjow.net/"
SRC_URI=""
LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="video_cards_nvidia"

DEPEND="virtual/ffmpeg
	media-libs/freeglut
	media-libs/glew
	media-libs/libsdl
	media-libs/opencv
	dev-qt/qtopengl
	dev-qt/qtscript
	dev-qt/qttest
	dev-qt/qtxmlpatterns
	virtual/jpeg"

RDEPEND="${DEPEND}"
PDEPEND="video_cards_nvidia? ( media-gfx/v3d )"

S="${S}/slowmoVideo"
CMAKE_USE_DIR="${S}/slowmoVideo"

src_install() {
	cmake-utils_src_install
	newicon slowmoVideo/slowmoUI/res/AppIcon.png "${PN}".png
	make_desktop_entry slowmoUI "slowmoVideo"
	make_desktop_entry slowmoFlowEdit "slowmoFlowEditor"
}
