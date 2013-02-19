# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/blam/blam-9999.ebuild,v 1.1 2012/12/06 20:25:23 brothermechanic Exp $

EAPI=4

inherit git-2

DESCRIPTION="A still image camera calibration toolkit"
HOMEPAGE="https://github.com/stuffmatic/blam"
EGIT_REPO_URI="https://github.com/stuffmatic/blam.git"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS=""

IUSE=""

DEPEND=""

RDEPEND="media-gfx/blender"

src_install() {
	dodir /usr/share/blender/2.64/scripts/addons/
	cp "${S}"/src/blam.py "${D}"/usr/share/blender/2.64/scripts/addons/
}
