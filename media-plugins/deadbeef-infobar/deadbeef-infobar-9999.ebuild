# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/deadbeef-infobar/deadbeef-infobar-9999.ebuild,v 1 2011/05/20 00:13:35 megabaks Exp $

EAPI=4

inherit mercurial

DESCRIPTION="Infobar plugin for DeadBeeF audio player. Shows lyrics and artist's biography for the current track."
HOMEPAGE="https://bitbucket.org/Not_eXist/deadbeef-infobar"
EHG_REPO_URI="https://bitbucket.org/dsimbiriatin/deadbeef-infobar"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="gtk2 gtk3"
REQUIRED_USE="|| ( ${IUSE} )"

DEPEND_COMMON="
	|| (
		media-sound/deadbeef[curl]
		media-sound/deadbeef[cover]
		media-sound/deadbeef[lastfm]
		)
	gtk2? ( media-sound/deadbeef[gtk2] )
	gtk3? ( media-sound/deadbeef[gtk3] )
	dev-libs/libxml2"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"
S="${WORKDIR}"

src_compile() {
	if use gtk2; then
	  emake gtk2
	fi

	if use gtk3; then
	  emake gtk3
	fi
}

src_install() {
	if use gtk2; then
	  insinto /usr/$(get_libdir)/deadbeef
	  doins gtk2/ddb_infobar_gtk2.so
	fi

	if use gtk3; then
	  insinto /usr/$(get_libdir)/deadbeef
	  doins gtk3/ddb_infobar_gtk3.so
	fi
}
