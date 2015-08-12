# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

EGIT_REPO_URI="https://github.com/kayosiii/kde-thumbnailer-blender.git"

inherit cmake-utils eutils git-2

DESCRIPTION="to create thumbnails for blend files in KDE"
HOMEPAGE="https://github.com/kayosiii/kde-thumbnailer-blender"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND=""

RDEPEND="${DEPEND}"

src_configure() {
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}
