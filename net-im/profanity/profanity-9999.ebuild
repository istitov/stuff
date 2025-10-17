# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_REPO_URI="https://github.com/profanity-im/profanity.git"

inherit autotools git-r3

DESCRIPTION="Ncurses based jabber client inspired by irssi"
HOMEPAGE="https://profanity-im.github.io/"

LICENSE="GPL-3+"
SLOT="0"
IUSE="gpg -gtk libnotify omemo otr plugins +themes xscreensaver"

RDEPEND=">=dev-db/sqlite-3.22
		>=dev-libs/glib-2.56:2
		>=dev-libs/libstrophe-0.9.2
		net-misc/curl
		sys-libs/ncurses
		sys-libs/readline
		gtk? ( >=x11-libs/gtk+-2.24.10:2 )
		gpg? ( app-crypt/gpgme )
		omemo? (
			>=net-libs/libsignal-protocol-c-2.3.2
			>=dev-libs/libgcrypt-1.7.0
		)
		otr? ( net-libs/libotr )
		plugins? ( dev-lang/python:= )
		xscreensaver? (
			x11-libs/libX11
			x11-libs/libXScrnSaver
		)
		libnotify? ( x11-libs/libnotify )"
DEPEND="${RDEPEND}
		sys-devel/autoconf-archive"

src_prepare() {
		default
		eautoreconf
}

src_configure() {
		econf \
			$(use_enable gpg pgp) \
			$(use_enable gtk icons-and-clipboard) \
			$(use_enable libnotify notifications) \
			$(use_enable omemo) \
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
		elog "  https://profanity-im.github.io/userguide.html"
		elog
}
