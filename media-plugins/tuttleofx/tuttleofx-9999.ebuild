# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/tuttleofx/tuttleofx-9999.ebuild,v 0.1 2014/12/05 16:11:23 brothermechanic Exp $

EAPI=5

inherit git-2 cmake-utils

DESCRIPTION="Open Shading Language"
HOMEPAGE="http://www.TuttleOFX.org"
EGIT_REPO_URI="https://github.com/tuttleofx/TuttleOFX.git"

LICENSE="LGPL-1"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	dev-libs/boost[python]
	dev-python/numpy
	media-libs/freetype
	x11-libs/libXt
	media-libs/lcms
	media-libs/opengtl
	dev-libs/libltdl
	media-libs/libpng
	media-libs/libcaca
	virtual/jpeg
	media-libs/glew
	media-libs/tiff
	media-libs/ilmbase
	media-libs/openexr
	media-libs/ctl
	media-gfx/imagemagick
	media-libs/libraw
	media-video/ffmpeg
	media-libs/openjpeg
	media-libs/glui
	media-libs/glew
	media-gfx/graphviz
	virtual/python-imaging"

RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}
		-DCMAKE_BUILD_TYPE="Release"
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DCTL_ILMIMF_LIB="/usr/lib/libIlmImf.so"
		"
	cmake-utils_src_configure
}
