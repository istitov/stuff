# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit git-2

DESCRIPTION="Blender add-on for finding free shortcuts"
HOMEPAGE="https://github.com/Antonioya/blender.git"
EGIT_REPO_URI="https://github.com/Antonioya/blender.git"

LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND=""

RDEPEND=""

src_install() {
	insinto /use/share/blender/2.73/scripts/addons/
	doins -r "${S}"/iskeyfree/src/iskeyfree.py
}
