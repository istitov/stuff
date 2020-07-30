# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit eutils autotools multilib

DESCRIPTION="Backported G729 implementation for Linphone"
HOMEPAGE="http://www.linphone.org"
SRC_URI="http://download.savannah.gnu.org/releases/linphone/plugins/sources/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
#Masked because of mediastreamer
IUSE=""

DOCS=( AUTHORS ChangeLog NEWS README )

DEPEND=">=net-libs/ortp-0.20.0
	>=media-libs/mediastreamer-2.8.2"
RDEPEND="${DEPEND}"

src_prepare(){
	# make sure to use host libtool version
	rm -f m4/libtool.m4 m4/lt*.m4 #282268
	eautoreconf
}

src_configure(){
	econf \
		--disable-strict \
		--libdir="${EPREFIX}/usr/$(get_libdir)"
}

src_install(){
	default
	find "${ED}" -name '*.la' -exec rm -f {} +
}
