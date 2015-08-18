# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils eutils

MY_P="OpenShadingLanguage"
MY_PV="${PV}beta"

DESCRIPTION="Open Shading Language"
HOMEPAGE="https://github.com/imageworks/OpenShadingLanguage"
SRC_URI="https://github.com/imageworks/${MY_P}/archive/Release-${MY_PV}.tar.gz -> ${PN}-${MY_PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="test tbb"

DEPEND="
	>=dev-libs/boost-1.57.0
	>=media-libs/openimageio-1.5.15
	sys-devel/bison
	sys-devel/flex
	>=media-libs/ilmbase-2.0
	tbb? ( dev-cpp/tbb )
	>=sys-devel/llvm-3.6.0[clang]"

RDEPEND=""

S="${WORKDIR}/${MY_P}-Release-${MY_PV}"

src_prepare() {
	epatch "${FILESDIR}"/shadingsys.cpp.patch
	epatch "${FILESDIR}"/llvm_util.h.patch
	epatch "${FILESDIR}"/llvm_util.cpp.patch
	epatch "${FILESDIR}"/src_liboslexec_CMakeLists_txt.patch
	epatch "${FILESDIR}"/src_testshade_CMakeLists_txt.patch
	epatch "${FILESDIR}"/src_testrender_CMakeLists_txt.patch
}

src_configure() {
	append-cxxflags -std=gnu++11
#	sed 's|-Werror|-Wno-error|' -i CMakeLists.txt || die
	local mycmakeargs=""
	mycmakeargs=(
		${mycmakeargs}
		$(cmake-utils_use_use tbb TBB)
		$(cmake-utils_use_build test TESTING)
		-DLLVM_LIB_DIR=/usr/lib64
#		-DUSE_CPP11=1
		-DUSE_EXTERNAL_PUGIXML=ON
		-DVERBOSE=1
		-DILMBASE_VERSION=2
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	mkdir -p "${D}"/usr/share/OSL/
	mv "${D}"/usr/{CHANGES,INSTALL,LICENSE,README.md,shaders,doc} "${D}"/usr/share/OSL/ || die
}
