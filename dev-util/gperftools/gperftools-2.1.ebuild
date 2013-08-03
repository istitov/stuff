# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="Collection of nifty performance analysis tools."
HOMEPAGE="https://code.google.com/p/gperftools/"
SRC_URI="http://gperftools.googlecode.com/files/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+cpu-profiler -debug heap-profiler heap-checker"

RDEPEND="sys-libs/libunwind"
DEPEND="${RDEPEND}"

src_configure() {
	econf \
		$(use_enable cpu-profiler) \
		$(use_enable heap-profiler) \
		$(use_enable heap-checker) \
		$(use_enable debug debugalloc)
}
