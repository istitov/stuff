# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/deadbeef-gnome/deadbeef-gnome-9999.ebuild,v 1 2011/05/20 00:13:35 megabaks Exp $

EAPI=4

inherit eutils git-2

DESCRIPTION="Adds support for Gnome multimedia keys to DeaDBeeF player by listening for DBus messages. Should work only in Gnome and Unity DEs."
HOMEPAGE="https://code.google.com/p/deadbeef-gnome-mmkeys/"
EGIT_REPO_URI="https://code.google.com/p/deadbeef-gnome-mmkeys/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="
	media-sound/deadbeef
	dev-libs/glib:2
	dev-libs/dbus-glib"

RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"

QA_TEXTRELS="usr/$(get_libdir)/deadbeef/ddb_gnome_mmkeys.so"

src_prepare(){
	sed 's|tcc|gcc|g' -i make.sh
}

src_compile(){
	./make.sh
}

src_install(){
	insinto /usr/$(get_libdir)/deadbeef
	doins ddb_gnome_mmkeys.so
}
