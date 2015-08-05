# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/animation-nodes/animation-nodes-9999.ebuild,v 1.1 2012/12/06 20:25:23 brothermechanic Exp $
EAPI=4

inherit git-2

DESCRIPTION="A node based system to create animations"
HOMEPAGE="https://github.com/JacquesLucke/animation-nodes"
EGIT_REPO_URI="https://github.com/JacquesLucke/animation-nodes.git"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND="media-gfx/blender"

RDEPEND="media-gfx/blender"

src_install() {
	insinto /use/share/blender/2.73/scripts/addons/animation-nodes
	doins -r "${S}"/*
}
