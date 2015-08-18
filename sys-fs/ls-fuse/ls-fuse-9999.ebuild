# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

EGIT_REPO_URI="git://github.com/pasis/ls-fuse.git"

inherit autotools git-2

DESCRIPTION="FUSE module to mount ls -lR output"
HOMEPAGE="https://github.com/pasis/ls-fuse"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
IUSE="-debug"

RDEPEND="sys-fs/fuse"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/${P/-/_}"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf $(use_enable debug)
}
