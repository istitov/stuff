# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit eutils

DESCRIPTION="Ncurses based jabber client inspired by irssi"
HOMEPAGE="http://www.profanity.im/"
SRC_URI="http://www.profanity.im/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libnotify otr pgp +themes xml xscreensaver"

RDEPEND=">=dev-libs/glib-2.26:2
		>=dev-libs/libstrophe-0.8-r1[xml=]
		net-misc/curl
		sys-libs/ncurses
		sys-libs/readline
		pgp? ( app-crypt/gpgme )
		otr? ( net-libs/libotr )
		xscreensaver? ( x11-libs/libXScrnSaver )
		libnotify? ( x11-libs/libnotify )"
DEPEND="${RDEPEND}"

src_configure() {
		econf \
			$(use_enable libnotify notifications) \
			$(use_enable otr) \
			$(use_enable pgp) \
			$(use_with themes) \
			$(use_with xml libxml2) \
			$(use_with xscreensaver)
}

pkg_postinst() {
		elog
		elog "User guide is available online:"
		elog "  http://www.profanity.im/userguide.html"
		elog
}
