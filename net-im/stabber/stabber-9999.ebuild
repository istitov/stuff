# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_REPO_URI="https://github.com/profanity-im/stabber.git"

inherit autotools git-r3

DESCRIPTION="Stubbed XMPP Server"
HOMEPAGE="https://github.com/profanity-im/stabber"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="dev-libs/expat
		>=dev-libs/glib-2.26:2
		net-libs/libmicrohttpd"
DEPEND="${RDEPEND}"

src_prepare() {
		default
		eautoreconf
}
