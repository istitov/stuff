# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="Collection of nifty performance analysis tools."
HOMEPAGE="https://code.google.com/p/gperftools/"
SRC_URI="http://gperftools.googlecode.com/files/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="sys-libs/libunwind"
DEPEND="${RDEPEND}"

src_prepare() {
		epatch "${FILESDIR}"/${PN}-fix-build.patch
}
