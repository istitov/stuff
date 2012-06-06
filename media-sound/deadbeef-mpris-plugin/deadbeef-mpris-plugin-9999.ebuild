# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/deadbeef-infobar/deadbeef-infobar-9999.ebuild,v 1 2011/05/20 00:13:35 megabaks Exp $

EAPI=4

inherit eutils autotools git-2

DESCRIPTION="Infobar plugin for DeadBeeF audio player. Shows lyrics and artist's biography for the current track."
HOMEPAGE="https://bitbucket.org/dsimbiriatin/deadbeef-infobar/wiki/Home"
EGIT_REPO_URI="git://github.com/kernelhcy/DeaDBeeF-MPRIS-plugin.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="
	media-sound/deadbeef"

RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"

src_prepare(){
  eautoreconf
  }