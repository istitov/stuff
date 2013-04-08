# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/deadbeef-remote/deadbeef-remote-9999.ebuild,v 1 2013/04/08 21:33:35 megabaks Exp $

EAPI=5

inherit eutils git-2

DESCRIPTION="Remote control plugin for DeadBeeF"
HOMEPAGE="https://github.com/Aerol/deadbeef-remote"
EGIT_REPO_URI="git://github.com/Aerol/deadbeef-remote.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="
	media-sound/deadbeef
	!media-sound/deadbeef-remote"

RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"
QA_TEXTRELS="usr/$(get_libdir)/deadbeef/remote.so"

src_prepare(){
	epatch "${FILESDIR}/remote.patch"
}

src_install(){
	mv client.exe deadbeef-remote
	dobin deadbeef-remote
	dodir usr/$(get_libdir)/deadbeef
	insinto /usr/$(get_libdir)/deadbeef
	doins remote.so
}
