# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit cmake-utils git-2

DESCRIPTION="Embree ray tracing kernels by intel"
HOMEPAGE="https://embree.github.io"
EGIT_REPO_URI="https://github.com/embree/embree.git"

LICENSE="Apache License Version 2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ispc"

RDEPEND="
	ispc? ( dev-lang/ispc )
	dev-cpp/tbb
	"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=""
	if ispc; then
		mycmakeargs="${mycmakeargs} -DENABLE_ISPC_SUPPORT=ON"
	else
		mycmakeargs="${mycmakeargs} -DENABLE_ISPC_SUPPORT=OFF"
	fi
	mycmakeargs="${mycmakeargs}
		  -DCMAKE_INSTALL_PREFIX=/usr"
	cmake-utils_src_configure
}


