# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
DESCRIPTION="Zoomable user interface with plugin applications"
SRC_URI="http://sourceforge.net/projects/${PN}/files/${PN}-${PV}/${PN}-${PV}.tar.bz2/download -> ${PN}-${PV}.tar.bz2"
HOMEPAGE="http://eaglemode.sourceforge.net/"
KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="GPL-3"
IUSE=""
DEPEND="dev-lang/perl
	x11-libs/libX11
	media-libs/jpeg
	media-libs/libpng
	media-libs/tiff
	<media-libs/xine-lib-1.2.0
	media-libs/freetype
	gnome-base/librsvg"
RDEPEND="${DEPEND}
	x11-terms/xterm
	app-text/ghostscript-gpl"

src_compile() {
	perl make.pl build continue=no || die "build failed"
}

src_install() {
	perl make.pl install "root=${D}" "dir=/usr/lib/eaglemode" menu=yes bin=yes \
	|| die "install failed"
}
