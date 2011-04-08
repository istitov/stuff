# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils

DESCRIPTION="Compiz Window Manager Plugins"
HOMEPAGE="http://www.compiz.org/"
SRC_URI="http://releases.compiz.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="
	!x11-plugins/compiz-fusion-plugins-main
	>=gnome-base/librsvg-2.14.0
	media-libs/jpeg
	x11-libs/cairo
	~x11-wm/compiz-${PV}
"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.19
	>=sys-devel/gettext-0.15
"

S="${WORKDIR}/${PN/compiz-/}"

src_configure() {
	mycmakeargs=(
		"-DCOMPIZ_DISABLE_SCHEMAS_INSTALL=ON"
		)
	cmake-utils_src_configure
}
