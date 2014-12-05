# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/opengtl/opengtl-0.9.18.ebuild,v 1.6 2014/01/11 09:14:50 mgorny Exp $

EAPI=5

MY_P="OpenGTL-${PV}"

inherit cmake-utils

DESCRIPTION="Collection of libraries for graphics transformation algorithms"
HOMEPAGE="http://opengtl.org/"
SRC_URI="http://download.opengtl.org/${MY_P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm x86"
IUSE="debug test"

RDEPEND="
	media-libs/libpng:0=
	(
		sys-devel/llvm
		sys-devel/llvm
	)
"
DEPEND="${RDEPEND}
	test? ( dev-util/lcov )
"

RESTRICT="test"

S=${WORKDIR}/${MY_P}

PATCHES=(
	"${FILESDIR}/${PN}-0.9.17-libpng-1.6.patch"
	"${FILESDIR}/${PN}-0.9.18-underlinking.patch"
	"${FILESDIR}/${PN}-0.9.18-llvm-3.4.patch"
	"${FILESDIR}/${PN}-0.9.18-llvm-3.5.patch"
)

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE
		$(cmake-utils_use debug OPENGTL_ENABLE_DEBUG_OUTPUT)
		$(cmake-utils_use test OPENGTL_BUILD_TESTS)
		$(cmake-utils_use test OPENGTL_CODE_COVERAGE)
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	newdoc OpenShiva/doc/reference/region.pdf OpenShiva.pdf
}
