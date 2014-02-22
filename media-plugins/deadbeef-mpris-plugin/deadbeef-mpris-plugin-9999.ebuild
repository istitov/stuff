# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/deadbeef-infobar/deadbeef-infobar-9999.ebuild,v 1 2011/05/20 00:13:35 megabaks Exp $

EAPI=5

inherit eutils autotools git-2

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
