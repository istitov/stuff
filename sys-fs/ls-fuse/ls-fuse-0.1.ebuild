# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

SRC_URI="mirror://sourceforge/lsfuse/${P}.tar.bz2"

DESCRIPTION="FUSE module to mount ls -lR output"
HOMEPAGE="https://github.com/pasis/ls-fuse"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="-debug"

RDEPEND="sys-fs/fuse"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_configure() {
	econf $(use_enable debug)
}
