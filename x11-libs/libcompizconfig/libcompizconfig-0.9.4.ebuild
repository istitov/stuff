# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit cmake-utils

DESCRIPTION="Compiz Configuration System"
HOMEPAGE="http://www.compiz.org/"
SRC_URI="http://releases.compiz.org/${PV}/compiz-${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="
	dev-libs/libxml2
	dev-libs/libxslt
	dev-libs/protobuf
	~x11-wm/compiz-${PV}
"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19
"
S="${WORKDIR}/${P}"
src_configure() {
	mycmakeargs=(
		"-DCOMPIZ_DISABLE_SCHEMAS_INSTALL=ON"
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	# Install the FindCompizConfig.cmake file
	insinto "/usr/share/cmake/Modules"
	doins "cmake/FindCompizConfig.cmake" || die "Failed to install FindCompizConfig.cmake"
}
