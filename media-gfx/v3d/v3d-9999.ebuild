# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

CMAKE_IN_SOURCE_BUILD="1"
EGIT_REPO_URI="https://github.com/Granjow/slowmoVideo.git"

inherit cmake-utils eutils git-2

DESCRIPTION="GPU implementation for slowmoVideo"
HOMEPAGE="http://slowmovideo.granjow.net/"
SRC_URI=""
LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="media-gfx/nvidia-cg-toolkit
	media-gfx/slowmovideo"

RDEPEND="${DEPEND}"

S="${S}/V3D"
CMAKE_USE_DIR="${S}/V3D"

src_configure() {
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}
	-DCG_COMPILER=/opt/bin/cgc
	-DCG_GL_LIBRARY=/opt/nvidia-cg-toolkit/lib64/libCgGL.so
	-DCG_INCLUDE_DIR=/opt/nvidia-cg-toolkit/include
	-DCG_LIBRARY=/opt/nvidia-cg-toolkit/lib64/libCg.so"
	-DSVFLOW_LIB=/usr/lib/libsVflow.a
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}
