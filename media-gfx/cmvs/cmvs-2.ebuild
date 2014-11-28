# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/cmvs/cmvs-2.ebuild,v 0.3 2014/11/21 09:30:12 brothermechanic Exp $

EAPI=5

inherit eutils

DESCRIPTION="Clustering Views for Multi-view Stereo"
HOMEPAGE="http://www.di.ens.fr/cmvs/"
SRC_URI="http://www.di.ens.fr/cmvs/cmvs-fix2.tar.gz"

LICENSE="GPL-1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	sci-libs/clapack
	dev-libs/libf2c
	media-libs/graclus
	dev-libs/boost
	sci-libs/gsl
	virtual/blas
	virtual/jpeg"
RDEPEND="${DEPEND}"

S="${WORKDIR}/cmvs/program/main/"

src_prepare() {
	rm *.so.*
	cd "${WORKDIR}"
	rm rm cmvs/program/base/pmvs/filter.cc
	#patch by Micky53 micky53@mail.ru
	epatch "${FILESDIR}"/fix_from_Micky53-v3.patch.bz2
}

src_compile() {
	emake YOUR_INCLUDE_PATH="${CXXFLAGS}" YOUR_LDLIB_PATH="${LDFLAGS} -L/usr/lib/graclus" depend
	emake YOUR_INCLUDE_PATH="${CXXFLAGS}" YOUR_LDLIB_PATH="${LDFLAGS} -L/usr/lib/graclus"
}

src_install() {
	dobin "${WORKDIR}"/cmvs/program/main/pmvs2 "${WORKDIR}"/cmvs/program/main/cmvs "${WORKDIR}"/cmvs/program/main/genOption
}
