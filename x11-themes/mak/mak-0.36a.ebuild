# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: bar-overlay/x11-themes/mak/mak-0.36a.ebuild,v 1.0 2013/12/14 15:01:00 brothermechanic Exp $

EAPI=5

inherit

DESCRIPTION="Mak-LionTaste Icons for KDE"
HOMEPAGE="http://kde-look.org/content/show.php/MaK-LionTaste+Icons+?content=149051"
SRC_URI="https://codeload.github.com/rhoconlinux/mak-lion-taste-icons/zip/master -> ${P}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="-minimal"

RDEPEND="minimal? ( !kde-base/oxygen-icons )"
DEPEND="app-arch/unzip"

RESTRICT="binchecks strip"

S="${WORKDIR}"/mak-lion-taste-icons-master/

src_install() {
	unpack ./MakLionTaste_036.tar.gz
	insinto /usr/share/icons
	doins -r ./MakLionTaste
}
