# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils bzr

DESCRIPTION="A showcase for GTK+ widgets"
HOMEPAGE="https://code.launchpad.net/~cimi/+junk/twf-gtk+3"
SRC_URI=""
EBZR_REPO_URI="lp:~cimi/+junk/twf-gtk+3"

LICENSE="GPL-2"
SLOT="gtk-3"
KEYWORDS=""
IUSE=""

RDEPEND="x11-libs/gtk+:3"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}"/${P}-stupid.patch
}

src_install() {
	emake DESTDIR="${D}" install || die
	mv "${D}"/usr/bin/twf{,-${SLOT}} || die
	dodoc README NEWS AUTHORS ChangeLog || die
}
