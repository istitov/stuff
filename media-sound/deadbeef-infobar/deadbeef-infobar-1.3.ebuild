# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/deadbeef-infobar/deadbeef-infobar-1.3.ebuild,v 1 2012/08/31 00:59:00 megabaks Exp $

EAPI=4

inherit eutils

DESCRIPTION="Infobar plugin for DeadBeeF audio player. Shows lyrics and artist's biography for the current track."
HOMEPAGE="https://bitbucket.org/dsimbiriatin/deadbeef-infobar/wiki/Home"
SRC_URI="https://bitbucket.org/dsimbiriatin/${PN}/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="gtk2 gtk3"
REQUIRED_USE="|| ( ${IUSE} )"

DEPEND_COMMON="
	gtk2? ( x11-libs/gtk+:2 media-sound/deadbeef[gtk2] )
	gtk3? ( x11-libs/gtk+:3 media-sound/deadbeef[gtk3] )
	dev-libs/libxml2"

RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"

src_prepare() {
	if ! use gtk3; then
	  sed -e "s|.*GTK3.*||g" -e "s|.*gtk3.*||g" -e "s|.*GTK+3.*||g"  -i Makefile
	fi

	if ! use gtk2; then
	  sed -e "s|.*GTK2.*||g" -e "s|.*gtk2.*||g" -e "s|.*GTK+2.*||g"  -i Makefile
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
