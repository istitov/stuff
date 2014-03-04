# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/deadbeef-infobar/deadbeef-infobar-9999.ebuild,v 1 2014/03/03 21:35:34 megabaks Exp $

EAPI="5"

inherit eutils git-2

DESCRIPTION="JACK output plugin for DeaDBeeF."
HOMEPAGE="https://gitorious.org/deadbeef-sm-plugins/jack"
EGIT_REPO_URI="git://gitorious.org/deadbeef-sm-plugins/jack.git"

LICENSE="as-is"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="
	media-sound/deadbeef
	media-sound/jack-audio-connection-kit"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

src_install(){
	insinto /usr/$(get_libdir)/deadbeef
	doins jack.so
	dodoc COPYING
}
