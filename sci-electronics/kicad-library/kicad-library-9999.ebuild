# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# rafaelmartins: Please try to keep the live ebuild synchronized with
# the latest snapshot ebuild. e.g.:
# cp kicad-YYYYMMDD_pXXXX.ebuild kicad-99999999-r1.ebuild

EAPI="5"

inherit cmake-utils fdo-mime gnome2-utils bzr

DESCRIPTION="Kicad library"
HOMEPAGE="http://www.kicad-pcb.org"
EBZR_REPO_URI="lp:~kicad-testing-committers/kicad/library"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS=""

CDEPEND=""
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

pkg_preinst() {
	gnome2_icon_savelist
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
