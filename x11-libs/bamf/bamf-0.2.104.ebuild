# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit autotools

DESCRIPTION="BAMF Application Matching Framework"
SRC_URI="http://launchpad.net/${PN}/0.2/0.2.204/+download/${PN}-${PV}.tar.gz"
HOMEPAGE="https://launchpad.net/bamf"
KEYWORDS="~x86 ~amd64"
SLOT="0"
LICENSE="LGPL-3"
IUSE="+gtk2"

DEPEND=">=dev-lang/vala-0.11.7
	dev-util/gtk-doc
	gnome-base/libgtop"

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i -e 's/vapigen/vapigen-0.12/' configure.in
	sed -i -e 's/-Werror//' configure.in

	if use gtk2;then
	  sed -i -e 's/AM_PATH_GTK_3_0/AM_PATH_GTK_2_0/' configure.in
	fi

	eautoreconf
}

src_configure() {
	if use gtk2;then
	  econf --with-gtk=2
	else
	  econf
	fi
}

src_compile() {
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
}
