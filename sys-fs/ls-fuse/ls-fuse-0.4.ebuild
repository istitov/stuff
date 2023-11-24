# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

SRC_URI="https://github.com/pasis/${PN}/releases/download/${PV}/${P}.tar.bz2"

DESCRIPTION="FUSE module to mount ls -lR output"
HOMEPAGE="https://github.com/pasis/ls-fuse"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

RDEPEND="sys-fs/fuse:0"
DEPEND="${RDEPEND}
	virtual/pkgconfig"
