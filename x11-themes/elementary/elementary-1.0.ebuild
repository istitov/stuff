# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: bar-overlay/x11-themes/elementary/elementary-1.0.ebuild,v 1.1 2013/12/14 13:01:00 brothermechanic Exp $

EAPI=5

inherit

DESCRIPTION="Elementary Icons for KDE"
HOMEPAGE="http://islingt0ner.deviantart.com/art/Elementary-Icons-for-KDE-154862803"
SRC_URI="http://fc09.deviantart.net/fs70/f/2010/051/e/a/Elementary_Icons_for_KDE__by_Islingt0ner.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="-minimal"

RDEPEND="minimal? ( !kde-base/oxygen-icons )"
DEPEND="app-arch/unzip"

RESTRICT="binchecks strip"

S="${WORKDIR}"

src_install() {
	cd "${WORKDIR}"
	unpack ./KDelementary.tar.gz
	dodir /usr/share/icons
	mv ./elementary "${D}"/usr/share/icons/
}
