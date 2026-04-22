# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="thread-pool"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="BS::thread_pool — a fast, lightweight single-header C++ thread pool"
HOMEPAGE="https://github.com/bshoshany/thread-pool"
SRC_URI="https://github.com/bshoshany/${MY_PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

src_install() {
	doheader include/BS_thread_pool.hpp
	einstalldocs
}
