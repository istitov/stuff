# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit git-2

DESCRIPTION="Parametric tool for architects (blender addon)"
HOMEPAGE="https://github.com/nortikin/sverchok/"
EGIT_REPO_URI="https://github.com/nortikin/sverchok.git"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS=""

IUSE=""

DEPEND=""

RDEPEND="media-gfx/blender"

src_install() {
	if v="/usr/share/blender/*";then
		insinto $v/scripts/addons/sverchok-master
		doins -r *
	fi
}
