# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit autotools eutils

DESCRIPTION="A set of symbols and convience functions that all indicators would like to use"
HOMEPAGE="http://launchpad.net/libindicator/"
SRC_URI="http://launchpad.net/${PN}/0.4/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+gtk2"

RDEPEND=">=x11-libs/gtk+-2.18:2
	>=dev-libs/glib-2.22:2
	>=dev-libs/dbus-glib-0.76
	!<gnome-extra/indicator-applet-0.2"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
#	epatch "${FILESDIR}"/${P}-missing_template.patch

	sed -i \
		-e 's:-Werror::' \
		{libindicator,tests,tools}/Makefile.am || die

	eautoreconf
}

src_configure() {
		if use gtk2;then
		  econf --with-gtk=2 --disable-dependency-tracking --disable-static
		else
		  econf --disable-dependency-tracking --disable-static
		fi
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS
	rm -f "${ED}"usr/lib*/*.la
}
