# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

DESCRIPTION="Mozilla's Universal Charset Detector C/C++ API"
HOMEPAGE="http://ftp.oops.org/pub/oops/libchardet"
#SRC_URI="ftp://ftp.oops.org/pub/oops/libchardet/libchardet-$PV.tar.bz2"
SRC_URI="libchardet-$PV.tar.bz2"
RESTRICT="fetch"

LICENSE="MPL"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

pkg_nofetch() {
    # Forbidden UserAgent "wget". Must be manually downloaded.
	einfo "Please download ${SRC_URI} from"
	einfo "ftp://ftp.oops.org/pub/oops/libchardet/libchardet-$PV.tar.bz2"
	einfo "and place it in ${DISTDIR}."
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}
