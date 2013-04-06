# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/deadbeef-infobar/deadbeef-infobar-9999.ebuild,v 1 2011/05/20 00:13:35 megabaks Exp $

EAPI=4

inherit eutils

DESCRIPTION="Infobar plugin for DeadBeeF audio player. Shows lyrics and artist's biography for the current track."
HOMEPAGE="https://bitbucket.org/dsimbiriatin/deadbeef-infobar/wiki/Home"
SRC_URI="https://bitbucket.org/dsimbiriatin/${PN}/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND_COMMON="
	|| (
		media-sound/deadbeef[curl]
		media-sound/deadbeef[cover]
		media-sound/deadbeef[lastfm]
		)
	x11-libs/gtk+:2
	dev-libs/libxml2
	media-sound/deadbeef[gtk2]"

RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"

src_install() {
	cd deadbeef-infobar/
	insinto /usr/$(get_libdir)/deadbeef
	doins ddb_infobar.so
}
