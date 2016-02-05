# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit eutils

DESCRIPTION="Mozilla's Universal Charset Detector C/C++ API"
HOMEPAGE="http://ftp.oops.org/pub/oops/libchardet"
SRC_URI="ftp://ftp.oops.org/pub/oops/libchardet/${P}.tar.bz2
		 http://stuff.tazhate.com/distfiles/${P}.tar.bz2"

LICENSE="MPL-1.1 LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

pkg_nofetch() {
	# Forbidden UserAgent "wget". Must be manually downloaded.
	einfo "Please download ${P} from"
	einfo "ftp://ftp.oops.org/pub/oops/libchardet/${P}.tar.bz2"
	einfo "and place it in ${DISTDIR}."
	einfo "If you want to download with wget, don't use default user-agent of wget! (Use -U option)"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}
