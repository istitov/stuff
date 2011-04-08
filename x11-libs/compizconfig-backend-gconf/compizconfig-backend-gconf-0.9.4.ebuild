# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit cmake-utils

DESCRIPTION="Compizconfig Gconf Backend"
HOMEPAGE="http://www.compiz.org/"
SRC_URI="http://releases.compiz.org/${PV}/compiz-${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="
	>=gnome-base/gconf-2.0
	>=x11-libs/libcompizconfig-${PV}
	>=x11-wm/compiz-${PV}
"
RDEPEND="${DEPEND}"

src_configure() {
	mycmakeargs=(
		"-DCOMPIZ_DISABLE_SCHEMAS_INSTALL=ON"
	)
	cmake-utils_src_configure
}
