# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/deadbeef-fb/deadbeef-fb-20120827.ebuild,v 1 2012/09/08 00:20:35 megabaks Exp $

EAPI=4

inherit eutils

DESCRIPTION="DeaDBeeF filebrowser plugin "
HOMEPAGE="http://sourceforge.net/projects/deadbeef-fb/"
SRC_URI="mirror://sourceforge/${PN}/${PN}_${PV}_src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="gtk2 gtk3"

DEPEND_COMMON="
	gtk2? ( x11-libs/gtk+:2 media-sound/deadbeef[gtk2] )
	gtk3? ( x11-libs/gtk+:3 media-sound/deadbeef[gtk3] )
	!media-sound/deadbeef-fb"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

S="${WORKDIR}/deadbeef-devel"

src_prepare() {
	epatch "${FILESDIR}/makefile.in.patch"
}

src_configure() {
	my_config="--disable-static
	  $(use_enable gtk3)
	  $(use_enable gtk2)"
	econf ${my_config}
}

src_install() {
	emake DESTDIR="${D}" install
	find "${D}" -name "${PN}-${PV}" -exec rm -rf {} +
}
