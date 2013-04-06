# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit git-2 flag-o-matic

DESCRIPTION="On board debugger driver for stm32-discovery boards"
HOMEPAGE="https://github.com/burjui/stlink"
EGIT_REPO_URI="git://github.com/karlp/stlink.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="
	virtual/libusb
	virtual/pkgconfig"
RDEPEND="${DEPEND}"

src_configure() {
	./autogen.sh
	econf
}

src_compile() {
	emake || die "Make failed!"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
