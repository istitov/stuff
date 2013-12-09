# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/osl/osl-9999.ebuild,v 1.1 2013/03/04 16:11:23 brothermechanic Exp $

EAPI=5

inherit git-2 cmake-utils

DESCRIPTION="Open Shading Language"
HOMEPAGE="http://code.google.com/p/openshadinglanguage/"
EGIT_REPO_URI="https://github.com/imageworks/OpenShadingLanguage.git"
EGIT_BRANCH="RB-1.4"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test tbb"

DEPEND="
	>=dev-libs/boost-1.49.0
	media-libs/openimageio
	sys-devel/clang
	sys-devel/bison
	sys-devel/flex
	media-libs/ilmbase
	tbb? ( dev-cpp/tbb )"

RDEPEND=""

src_configure() {
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}
		$(cmake-utils_use_use tbb TBB)
		$(cmake-utils_use_build test TESTING)
		-DUSE_EXTERNAL_PUGIXML=ON
		-DLLVM_STATIC=0"
	if use test ; then
	mycmakeargs="${mycmakeargs} -DBUILD_TESTING=ON"
	else
	mycmakeargs="${mycmakeargs} -DBUILD_TESTING=OFF"
	fi

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install 
	mkdir -p ${D}/usr/share/OSL/
        mv ${D}/usr/{CHANGES,INSTALL,LICENSE,README.md,shaders,doc} ${D}/usr/share/OSL/ || die
}
