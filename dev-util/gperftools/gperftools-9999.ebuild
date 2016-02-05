# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

EGIT_REPO_URI="https://github.com/gperftools/gperftools.git"

inherit autotools git-2

DESCRIPTION="Collection of nifty performance analysis tools."
HOMEPAGE="https://github.com/gperftools/gperftools"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="sys-libs/libunwind"
DEPEND="${RDEPEND}"

src_prepare() {
	eautoreconf
}
