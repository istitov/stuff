# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2

DESCRIPTION="A still image camera calibration toolkit"
HOMEPAGE="https://github.com/stuffmatic/blam"
EGIT_REPO_URI="https://github.com/stuffmatic/blam.git"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND=""

RDEPEND=""

src_install() {
	insinto /use/share/blender/2.73/scripts/addons/
	doins -r "${S}"/src/blam.py
}
