# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

EGIT_REPO_URI="git://github.com/boothj5/profanity.git"

inherit autotools git-2

DESCRIPTION="Ncurses based jabber client inspired by irssi"
HOMEPAGE="http://www.profanity.im/"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
IUSE="libnotify otr pgp +themes xscreensaver"

RDEPEND=">=dev-libs/glib-2.26:2
		>=dev-libs/libstrophe-0.8.9
		net-misc/curl
		sys-libs/ncurses
		sys-libs/readline
		pgp? ( app-crypt/gpgme )
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
			$(use_enable pgp) \
			$(use_with themes) \
			$(use_with xscreensaver)
}

pkg_postinst() {
		elog
		elog "User guide is available online:"
		elog "  http://www.profanity.im/userguide.html"
		elog
}
