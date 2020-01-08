# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Ncurses based jabber client inspired by irssi"
HOMEPAGE="http://www.profanity.im/"
SRC_URI="http://www.profanity.im/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gpg -gtk libnotify otr plugins +themes xscreensaver"

RDEPEND=">=dev-libs/glib-2.26:2
		|| (
			>=dev-libs/libstrophe-0.9.0
			>=dev-libs/libmesode-0.9.0
		)
		net-misc/curl
		sys-libs/ncurses
		sys-libs/readline
		gtk? ( >=x11-libs/gtk+-2.24.10:2 )
		gpg? ( app-crypt/gpgme )
		otr? ( net-libs/libotr )
		plugins? ( dev-lang/python )
		xscreensaver? ( x11-libs/libXScrnSaver )
		libnotify? ( x11-libs/libnotify )"
DEPEND="${RDEPEND}"

src_configure() {
		econf \
			$(use_enable gpg pgp) \
			$(use_enable gtk icons) \
			$(use_enable libnotify notifications) \
			$(use_enable otr) \
			$(use_enable plugins) \
			$(use_enable plugins python-plugins) \
			$(use_enable plugins c-plugins) \
			$(use_with themes) \
			$(use_with xscreensaver)
}

pkg_postinst() {
		elog
		elog "User guide is available online:"
		elog "  http://www.profanity.im/userguide.html"
		elog
}
