# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/pba/pba-1.0.5.ebuild,v 0.1 2013/11/19 12:24:12 brothermechanic Exp $

EAPI=5

inherit eutils

DESCRIPTION="Multicore Bundle Adjustment"
HOMEPAGE="http://grail.cs.washington.edu/projects/mcba/"
SRC_URI="http://grail.cs.washington.edu/projects/mcba/pba_v1.0.5.zip"

LICENSE="GPL-1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cuda"

DEPEND="
	cuda? ( dev-util/nvidia-cuda-toolkit )"
RDEPEND="${DEPEND}"

MAKEOPTS="-j1"

S="${WORKDIR}/pba"

src_prepare() {
	rm makefile src/pba/SparseBundleCU.h src/pba/pba.h 
	epatch "${FILESDIR}"/include.patch
	if use cuda; then
		epatch "${FILESDIR}"/cuda.patch
	else
		mv makefile_no_gpu makefile
	fi
	chmod +x makefile
}

src_install() {
	dobin ${S}/bin/driver
	dolib ${S}/bin/libpba.so
	insinto /usr/include
	doins ${S}/bin/libpba.a
	dodoc doc/manual.pdf
}
