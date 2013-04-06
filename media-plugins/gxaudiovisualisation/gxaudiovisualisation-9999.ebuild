# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit git-2

DESCRIPTION="Blender Python script for audio visualisation"
HOMEPAGE="http://blenderartists.org/forum/showthread.php?251207-SCRIPT-Simple-Sound-Visualizer"
EGIT_REPO_URI="https://github.com/gethiox/GXAudioVisualisation.git"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND=""

RDEPEND=""

src_install() {
	if v="/usr/share/blender/*";then
		dodir $v/scripts/
		cp "${S}"/*.py "${D}"$v/scripts/
	fi
}
