# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Binary I/O stream class library"
HOMEPAGE="https://github.com/adplug/libbinio"
SRC_URI="https://github.com/adplug/${PN}/releases/download/${P}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs"

BDEPEND="sys-apps/texinfo"

PATCHES=(
	"${FILESDIR}"/${P}-cstdio.patch
)

src_configure() {
	econf $(use_enable static-libs static)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
