# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=4

EGIT_REPO_URI="https://github.com/boothj5/stabber.git"

inherit autotools git-r3

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

src_prepare() {
		eautoreconf
}
