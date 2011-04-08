# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

if [[ ${PV} != *9999* ]]; then
	SRC_URI="http://releases.compiz.org/${PV}/${P}.tar.bz2"
	KEYWORDS="~x86 ~amd64"
else
	EGIT_HAS_SUBMODULES=true
	GIT_ECLASS="git"
	EGIT_REPO_URI="git://anongit.compiz.org/compiz/plugins-extra"
	SRC_URI=""
	KEYWORDS=""
fi

inherit cmake-utils ${GIT_ECLASS}

DESCRIPTION="Compiz Window Manager Extra Plugins"
HOMEPAGE="http://www.compiz.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="gnome"

RDEPEND="
	!x11-plugins/compiz-fusion-plugins-extra
	>=gnome-base/librsvg-2.14.0
	media-libs/jpeg
	x11-libs/cairo
	~x11-plugins/compiz-plugins-main-${PV}
	~x11-wm/compiz-${PV}
"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.19
	>=sys-devel/gettext-0.15
	x11-libs/cairo
	gnome? ( gnome-base/gconf )
"

S="${WORKDIR}/${PN/compiz-/}"

src_configure() {
	mycmakeargs=(
		"-DCOMPIZ_DISABLE_SCHEMAS_INSTALL=ON"
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}
