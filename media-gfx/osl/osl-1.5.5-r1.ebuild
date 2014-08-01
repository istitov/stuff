# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/osl/osl-9999.ebuild,v 1.1 2013/03/04 16:11:23 megabaks Exp $

EAPI=5

inherit cmake-utils

MY_P="OpenShadingLanguage"
MY_PV="Release-${PV}dev"

DESCRIPTION="Open Shading Language"
HOMEPAGE="https://github.com/imageworks/OpenShadingLanguage"
SRC_URI="https://github.com/imageworks/${MY_P}/archive/${MY_PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="test tbb"

DEPEND="
	dev-libs/boost
	media-libs/openimageio
	sys-devel/clang
	sys-devel/bison
	sys-devel/flex
	>=media-libs/ilmbase-2.0
	tbb? ( dev-cpp/tbb )
	sys-devel/llvm"

RDEPEND=""

S="${WORKDIR}/${MY_P}-${MY_PV}"

src_configure() {
	sed 's|-Werror|-Wno-error|' -i CMakeLists.txt || die
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}
		$(cmake-utils_use_use tbb TBB)
		$(cmake-utils_use_build test TESTING)
		-DUSE_EXTERNAL_PUGIXML=ON
		-DLLVM_STATIC=0
		-DILMBASE_VERSION=2"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	mkdir -p "${D}"/usr/share/OSL/
	mv "${D}"/usr/{CHANGES,INSTALL,LICENSE,README.md,shaders,doc} "${D}"/usr/share/OSL/ || die
}
