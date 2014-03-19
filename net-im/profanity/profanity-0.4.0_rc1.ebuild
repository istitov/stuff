# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

EGIT_REPO_URI="git://github.com/boothj5/profanity.git"
EGIT_COMMIT="0.4.0.rc1"

inherit autotools git-2

DESCRIPTION="Ncurses based jabber client inspired by irssi"
HOMEPAGE="http://www.profanity.im/"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libnotify otr xml xscreensaver"

RDEPEND="dev-libs/glib:2
		>=dev-libs/libstrophe-0.8-r1[xml=]
		dev-libs/openssl
		net-misc/curl
		sys-libs/ncurses
		otr? ( net-libs/libotr )
		xscreensaver? ( x11-libs/libXScrnSaver )
		libnotify? ( x11-libs/libnotify )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P/-/_}"

src_prepare() {
		eautoreconf
}

src_configure() {
		econf \
			$(use_enable libnotify notifications) \
			$(use_enable otr) \
			$(use_with xml libxml2) \
			$(use_with xscreensaver)
}

pkg_postinst() {
		elog
		elog "User guide is available online:"
		elog "  http://www.profanity.im/userguide.html"
		elog
}
