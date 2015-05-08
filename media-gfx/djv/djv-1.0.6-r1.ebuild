# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/djv/djv-9999.ebuild,v 1.0 2014/11/12 20:00:00 brothermechanic Exp $

EAPI="5"

inherit cmake-utils eutils git-2

MY_P=${PN}-${PV}

DESCRIPTION="Professional movie playback and image processing software for the film and computer animation industries."
HOMEPAGE="http://djv.sf.net"
EGIT_REPO_URI="git://git.code.sf.net/p/djv/git"
#EGIT_BRANCH=""
EGIT_TAG="1.0.6"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~amd64 ~ppc ~x86"
# IUSE="ffmpeg jpeg png quicktime tiff qt"

RDEPEND="
		>=dev-qt/qtopengl-5.3.2
		>=dev-qt/qtconcurrent-5.3.2
		>=dev-qt/linguist-tools-5.3.2
		>=media-libs/openexr-2.2.0
		>=media-libs/glew-1.11.0
		>=media-video/ffmpeg-2.4.1
		virtual/jpeg
		>=media-libs/libpng-1.6.13
		>=media-libs/libquicktime-1.2.4
		>=media-libs/tiff-4.0.3
"

DEPEND="${RDEPEND}
	>=dev-util/cmake-2.4.4"

S=${WORKDIR}/${MY_P}

#src_prepare() {
#	epatch "${FILESDIR}"/djvJpegPlugin.patch || die
#	sed -i -e "s:djvPackageThirdParty true:djvPackageThirdParty false:" CMakeLists.txt || die
#}

src_install() {
	cmake-utils_src_install
	newicon "${FILESDIR}"/djv_view.png "${PN}".png
	make_desktop_entry djv_view "DJV View" djv AudioVideo "MimeType=image/exr;image/openexr;image/x-exr;"
}
