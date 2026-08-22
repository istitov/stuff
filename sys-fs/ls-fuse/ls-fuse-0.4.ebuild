# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="FUSE module to mount ls -lR output"
HOMEPAGE="https://github.com/pasis/ls-fuse"
SRC_URI="https://github.com/pasis/${PN}/releases/download/${PV}/${P}.tar.bz2"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="debug"

RDEPEND="sys-fs/fuse:0"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${PN}-0.4-const.patch
	"${FILESDIR}"/${PN}-0.4-respect-flags-configure.patch
)

src_configure() {
	econf $(use_enable debug)
}
