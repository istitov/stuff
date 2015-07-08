# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit cmake-utils eutils

DESCRIPTION="An Open-Source subdivision surface library"
HOMEPAGE="http://graphics.pixar.com/opensubdiv"
SRC_URI="https://github.com/PixarAnimationStudios/OpenSubdiv/archive/v3_0_0.tar.gz -> ${P}.tar.gz"

LICENSE="Modified Apache 2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="media-libs/glew
	media-libs/glfw
	dev-cpp/tbb
	sys-libs/zlib
	cuda? ( dev-util/nvidia-cuda-toolkit )
	ptex? ( media-libs/ptex )
	"
DEPEND="${RDEPEND}"
S=${WORKDIR}/OpenSubdiv-3_0_0	
src_configure() {
	local mycmakeargs=""
	if !use cuda; then
	    -DNO_CUDA=1
	fi
	if !use ptex; then
	    -DNO_PTEX=1
	fi
	mycmakeargs=(
		${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DNO_MAYA=1 
		-DNO_DOC=1
		-DNO_OPENCL=1
	)
	cmake-utils_src_configure
}
