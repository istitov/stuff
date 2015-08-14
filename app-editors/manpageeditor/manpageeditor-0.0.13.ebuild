# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit autotools eutils fdo-mime gnome2-utils

DESCRIPTION="Man Page Editor"
HOMEPAGE="http://keithhedger.hostingsiteforfree.com/pages/manpageeditor/help.html"
MY_PN="ManPageEditor"
SRC_URI="http://keithhedger.hostingsiteforfree.com/zips/${PN}/${MY_PN}-${PV}.tar.gz
		 http://stuff.tazhate.com/distfiles/${MY_PN}-${PV}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="spell"

RDEPEND="
	spell? ( app-text/aspell )
	x11-misc/xdg-utils
	x11-libs/gtk+:2
	x11-libs/gtksourceview:2.0"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare(){
	# fdo
	sed \
		-e 's|x-maneditdoc|x-maneditdoc;|' \
		-i ManPageEditor/resources/applications/ManPageEditor.desktop
	cp "${FILESDIR}/Makefile.am" Makefile.am
	eautoreconf
}

src_configure(){
	econf $(use_enable spell aspell)
}

src_install(){
	emake DESTDIR="${D}" install
	doicon --size 256 ManPageEditor/resources/documenticons/256/maneditdoc.png
	doicon --size 128 ManPageEditor/resources/documenticons/128/maneditdoc.png
	doicon --size 48 ManPageEditor/resources/documenticons/48/maneditdoc.png
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}
