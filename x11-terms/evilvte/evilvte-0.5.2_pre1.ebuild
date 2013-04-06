# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/evilvte/evilvte-0.5.0.ebuild,v 1.1 2011/11/20 04:01:55 ssuominen Exp $

EAPI=4
MY_P=${P/_/\~}
inherit toolchain-funcs savedconfig

DESCRIPTION="VTE based, super lightweight terminal emulator"
HOMEPAGE="http://www.calno.com/evilvte"
SRC_URI="http://www.calno.com/${PN}/${MY_P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk3"

RDEPEND="x11-libs/vte:2.90
	|| ( gtk3? ( x11-libs/gtk+:3 ) x11-libs/gtk+:2 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S=${WORKDIR}/${MY_P}

DOCS=( ChangeLog )

src_prepare() {
	use savedconfig && restore_config src/config.h
}

src_configure() {
	tc-export CC
	if use gtk3;then
	  mygtk="3.0"
	else
	  mygtk="2.0"
	fi
	./configure --prefix=/usr --with-gtk=${mygtk} || die
}

src_compile() {
	emake
}

src_install() {
	default
	save_config src/config.h
}
