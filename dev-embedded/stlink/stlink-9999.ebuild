# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit git-r3 flag-o-matic

DESCRIPTION="On board debugger driver for stm32-discovery boards"
HOMEPAGE="https://github.com/burjui/stlink"
EGIT_REPO_URI="git://github.com/karlp/stlink.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	virtual/libusb:=
	virtual/pkgconfig"
RDEPEND="
	virtual/libusb:=
"

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
