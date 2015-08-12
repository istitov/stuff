# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="A fast graph clustering software"
HOMEPAGE="http://www.cs.utexas.edu/users/dml/Software/graclus.html"
SRC_URI="http://www.cs.utexas.edu/users/dml/Software/graclus1.2.tar.gz"

LICENSE="GPL-1+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="abi_x86_64"

DEPEND="
	sci-libs/clapack
	dev-libs/libf2c"
RDEPEND="${DEPEND}"

PDEPEND=""

S="${WORKDIR}/graclus1.2/"

src_prepare() {
	if use abi_x86_64; then
		epatch "${FILESDIR}"/amd64.patch
	fi
}

src_install() {
	insinto /usr/lib/graclus
	doins -r "${S}"/*
}
