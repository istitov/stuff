# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit out-of-source

DESCRIPTION="A free, cross-platform, hardware independent AdLib sound player library"
HOMEPAGE="https://adplug.github.io/"
SRC_URI="https://github.com/adplug/${PN}/releases/download/${P}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="debug static-libs"

RDEPEND=">=dev-cpp/libbinio-1.4"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

my_src_configure() {
	econf \
		$(use_enable debug) \
		$(use_enable static-libs static)
}

my_src_install_all() {
	einstalldocs
	find "${ED}" -name '*.la' -delete || die
}
