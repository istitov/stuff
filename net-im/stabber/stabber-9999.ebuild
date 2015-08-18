# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

EGIT_REPO_URI="git://github.com/boothj5/stabber.git"

inherit autotools git-2

DESCRIPTION="Stubbed XMPP Server"
HOMEPAGE="https://github.com/boothj5/stabber"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="dev-libs/expat
		>=dev-libs/glib-2.26:2
		net-libs/libmicrohttpd"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P/-/_}"

src_prepare() {
		eautoreconf
}
