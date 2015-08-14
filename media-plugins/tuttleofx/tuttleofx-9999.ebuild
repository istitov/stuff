# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2 cmake-utils

DESCRIPTION="Open Shading Language"
HOMEPAGE="http://www.TuttleOFX.org"
EGIT_REPO_URI="https://github.com/tuttleofx/TuttleOFX.git"

LICENSE="LGPL-3 GPL-3 TuttleOFX"
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
	dev-libs/libltdl:0
	media-libs/libpng:0
	media-libs/libcaca
	virtual/jpeg:0
	media-libs/glew
	media-libs/tiff:0
	media-libs/ilmbase
	media-libs/openexr
	media-libs/ctl
	media-gfx/imagemagick
	media-libs/libraw
	media-video/ffmpeg
	media-libs/openjpeg:=
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
