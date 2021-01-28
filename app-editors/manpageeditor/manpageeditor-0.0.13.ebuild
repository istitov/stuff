# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit autotools eutils xdg-utils gnome2-utils

DESCRIPTION="Man Page Editor"
HOMEPAGE="https://sites.google.com/site/keithhedgersyard/manpageeditor"
MY_PN="ManPageEditor"
SRC_URI="https://dl.dropboxusercontent.com/s/e882fqpz34h0h24/${MY_PN}-${PV}.tar.gz
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
	xdg-utils_desktop_database_update
	xdg-utils_mime_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg-utils_desktop_database_update
	xdg-utils_mime_database_update
	gnome2_icon_cache_update
}
