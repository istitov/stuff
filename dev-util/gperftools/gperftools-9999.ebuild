# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit autotools subversion

DESCRIPTION="Collection of nifty performance analysis tools."
HOMEPAGE="https://code.google.com/p/gperftools/"
ESVN_REPO_URI="http://${PN}.googlecode.com/svn/trunk"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="sys-libs/libunwind"
DEPEND="${RDEPEND}"

src_prepare() {
	eautoreconf
}
