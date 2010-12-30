# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
 
DESCRIPTION="mplayer with patches add VA API support"
HOMEPAGE="http://www.splitted-desktop.com/~gbeauchesne/${PN}/"
SRC_URI="http://www.splitted-desktop.com/~gbeauchesne/${PN}/${P}-FULL.tar.bz2"
  
LICENSE=""
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
   
DEPEND="x11-libs/libva
|| ( x11-libs/xvba-video x11-libs/vdpau-video )
"
RDEPEND="${DEPEND}"

src_compile() {
	./checkout-patch-build.sh
}

src_install() {
	mv ${PN}/mplayer ${PN}/mplayer-vaapi
	into /usr/local/
	dobin ${PN}/mplayer-vaapi
}