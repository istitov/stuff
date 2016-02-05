# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit eutils git-2

DESCRIPTION="A simple stereo widener plugin for DeaDBeeF."
HOMEPAGE="https://gitorious.org/deadbeef-sm-plugins/stereo-widener"
EGIT_REPO_URI="git://gitorious.org/deadbeef-sm-plugins/stereo-widener.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="media-sound/deadbeef"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

src_install(){
	insinto /usr/$(get_libdir)/deadbeef
	doins stereo_widener.so
}
