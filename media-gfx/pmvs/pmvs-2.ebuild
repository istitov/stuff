# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/pmvs/pmvs-2.ebuild,v 0.1 2013/11/19 12:40:12 brothermechanic Exp $

EAPI=5

inherit eutils

DESCRIPTION="Patch-based Multi-view Stereo Software"
HOMEPAGE="http://www.di.ens.fr/pmvs/"
SRC_URI="http://www.di.ens.fr/pmvs/pmvs-2-fix0.tar.gz"

LICENSE="GPL-1+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	sci-libs/clapack
	dev-libs/libf2c"
RDEPEND="${DEPEND}"

S="${WORKDIR}/pmvs-2/program/main/"

src_prepare() {
	rm *.so.*
	cd ${WORKDIR}
	#patch by Micky53 micky53@mail.ru
	epatch "${FILESDIR}"/lapack.patch
}

src_compile() {
	cd ${S}
	make depend
	emake
}

src_install() {
	dobin ${WORKDIR}/pmvs-2/program/main/pmvs2
	dodoc ${WORKDIR}/pmvs-2/license/libgfx-license.html
}
