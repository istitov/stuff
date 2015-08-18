# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

EGIT_REPO_URI="git://github.com/pasis/pppoat.git"

inherit autotools git-2

DESCRIPTION="PPP over Any Transport"
HOMEPAGE="https://github.com/pasis/pppoat"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="-extra +xmpp"

RDEPEND="xmpp? ( dev-libs/libcouplet )"
DEPEND="${RDEPEND}
		virtual/pkgconfig"

S="${WORKDIR}/${P/-/_}"

src_prepare() {
		eautoreconf
}

src_configure() {
		econf $(use_enable xmpp) \
			$(use_enable extra loop)
}
