# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3

DESCRIPTION="Stubbed XMPP Server"
HOMEPAGE="https://github.com/profanity-im/stabber"
EGIT_REPO_URI="https://github.com/profanity-im/${PN}.git"

LICENSE="GPL-3+"
SLOT="0"

RDEPEND="
	>=dev-libs/expat-2.0.0
	>=dev-libs/glib-2.26:2
	>=net-libs/libmicrohttpd-0.9.71
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
	eautoreconf
}
