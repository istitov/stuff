# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/cmvs/cmvs-2.ebuild,v 0.1 2013/11/19 13:30:12 brothermechanic Exp $

EAPI=5

inherit eutils

DESCRIPTION="Clustering Views for Multi-view Stereo"
HOMEPAGE="http://www.di.ens.fr/cmvs/"
SRC_URI="http://www.di.ens.fr/cmvs/cmvs-fix2.tar.gz"

LICENSE="GPL-1+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	sci-libs/clapack
	dev-libs/libf2c"
RDEPEND="${DEPEND}"

S="${WORKDIR}/cmvs/program/main/"

src_prepare() {
	rm *.so.*
	cd ${WORKDIR}
	#patch by Micky53 micky53@mail.ru
	epatch "${FILESDIR}"/fix_from_Micky53.patch
}

src_compile() {
	cd ${S}
	make depend
	emake
}

src_install() {
	dobin ${WORKDIR}/cmvs/program/main/pmvs2 ${WORKDIR}/cmvs/program/main/cmvs ${WORKDIR}/cmvs/program/main/genOption
}
