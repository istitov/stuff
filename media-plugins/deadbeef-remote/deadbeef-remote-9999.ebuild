# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils git-r3

DESCRIPTION="Remote control plugin for DeadBeeF"
HOMEPAGE="https://github.com/Aerol/deadbeef-remote"
EGIT_REPO_URI="git://github.com/Aerol/deadbeef-remote.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="media-sound/deadbeef"

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
