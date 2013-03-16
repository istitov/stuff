# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=3
# NOTES:
# 1- use flag 'pgm' (OpenPGM support) must be masked by profiles for ARM archs;


WANT_AUTOCONF="2.5"

DESCRIPTION="ZeroMQ is a brokerless messaging kernel with extremely high performance."
HOMEPAGE="http://www.zeromq.org"
SRC_URI="http://download.zeromq.org/${P/_/-}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="pgm test static-libs"

RDEPEND=""
DEPEND="pgm? (
virtual/pkgconfig
=net-libs/openpgm-5.1.118
)
sys-apps/util-linux"

src_prepare() {
	#einfo "Removing bundled OpenPGM library"
	#rm -r "${S}"/foreign/openpgm/libpgm* || die
	#eautoreconf
	mv ${PN}-3.2.0 ${P} # Move source to where portage expects it
}

src_configure() {
	local myconf
	use pgm && myconf="--with-system-pgm" || myconf="--without-pgm"
	econf \
		$(use_enable static-libs static) \
		$myconf
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc NEWS README AUTHORS ChangeLog || die "dodoc failed"
	doman doc/*.[1-9] || die "doman failed"

	# remove useless .la files
	find "${D}" -name '*.la' -delete

	# remove useless .a (only for non static compilation)
	use static-libs || find "${D}" -name '*.a' -delete
}
