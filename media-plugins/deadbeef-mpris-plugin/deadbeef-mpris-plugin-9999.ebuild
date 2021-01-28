# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils autotools git-r3

DESCRIPTION="MPRIS-plugin for deadbeef"
HOMEPAGE="https://github.com/Jerry-Ma/DeaDBeeF-MPRIS-plugin"
EGIT_REPO_URI="git://github.com/Jerry-Ma/DeaDBeeF-MPRIS-plugin.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="media-sound/deadbeef"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

src_prepare(){
	eautoreconf
}

src_configure(){
	econf \
		--enable-static=no \
		--enable-shared=yes \
		--disable-dependency-tracking
}
