# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit git-2

DESCRIPTION="A still image camera calibration toolkit"
HOMEPAGE="https://github.com/Radivarig/UvSquares"
EGIT_REPO_URI="https://github.com/Radivarig/UvSquares.git"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND=""

RDEPEND=""

src_install() {
	if v="/usr/share/blender/*";then
	dodir $v/scripts/addons/
	cp "${S}"/uv_squares.py "${D}"$v/scripts/addons/ || die
	fi
}
