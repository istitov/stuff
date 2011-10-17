# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit autotools

DESCRIPTION="Ubuntu's scrollbars"
HOMEPAGE="https://launchpad.net/ayatana-scrollbar"
SRC_URI="http://launchpad.net/ayatana-scrollbar/0.2/${PV}/+download/${PN}-${PV}.tar.gz"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

CDEPEND=""
DEPEND="x11-libs/gtk:2+[overlay]"
RDEPEND="${DEPEND}"

src_configure(){
	econf --with-gtk=2
}