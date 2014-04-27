# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/sverchok/sverchok-9999.ebuild,v 1.1 2014/04/27 brothermechanic Exp $

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
