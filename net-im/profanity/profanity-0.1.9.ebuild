# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit autotools

DESCRIPTION="Ncurses based jabber client inspired by irssi"
HOMEPAGE="http://www.boothj5.com/profanity.shtml"
SRC_URI="https://github.com/downloads/boothj5/${PN}/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libnotify xml"

RDEPEND="dev-libs/expat
		dev-libs/glib:2
		dev-libs/libstrophe[xml=]
		dev-libs/libxml2
		dev-libs/openssl
		net-misc/curl
		sys-libs/ncurses
		libnotify? ( x11-libs/libnotify )"
DEPEND="${RDEPEND}"

src_prepare() {
		eautoreconf
}

src_configure() {
		econf $(use_with xml libxml2)
}
