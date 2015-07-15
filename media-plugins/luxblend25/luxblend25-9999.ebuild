# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit mercurial

DESCRIPTION="Blender 2.5 exporter for luxrender"
HOMEPAGE="http://www.luxrender.net"
EHG_REPO_URI="http://src.luxrender.net/luxblend25"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=">=media-gfx/blender-2.50"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/src/luxrender
	    insinto ${VER}/scripts/presets/
	    doins -r "${S}"/src/presets/luxrender
	fi
}
