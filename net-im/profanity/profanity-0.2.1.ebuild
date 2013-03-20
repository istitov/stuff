# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="Ncurses based jabber client inspired by irssi"
HOMEPAGE="http://www.profanity.im/"
SRC_URI="http://www.profanity.im/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libnotify xml xscreensaver"

RDEPEND="dev-libs/glib:2
		dev-libs/libstrophe[xml=]
		dev-libs/openssl
		net-misc/curl
		sys-libs/ncurses
		xscreensaver? ( x11-libs/libXScrnSaver )
		libnotify? ( x11-libs/libnotify )"
DEPEND="${RDEPEND}"

src_configure() {
		econf $(use_with xml libxml2)
}
