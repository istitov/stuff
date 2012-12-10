# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit cmake-utils git

DESCRIPTION="create thumbnails for blend files in KDE"
HOMEPAGE="https://github.com/kayosiii/kde-thumbnailer-blender"
EGIT_REPO_URI="https://github.com/kayosiii/kde-thumbnailer-blender.git"

LICENSE="BSD"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND=""

RDEPEND="${DEPEND}"

src_configure() {
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install || die

}
