# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools desktop xdg

DESCRIPTION="Man Page Editor"
HOMEPAGE="https://github.com/KeithDHedger/ManPageEditor"
MY_PN="ManPageEditor"
SRC_URI="https://github.com/KeithDHedger/${MY_PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="spell"

RDEPEND="
	x11-libs/gtk+:2
	x11-libs/gtksourceview:2.0
	x11-misc/xdg-utils
	spell? ( app-text/aspell )
"
DEPEND="${RDEPEND}"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf $(use_enable spell aspell)
}

src_install() {
	emake DESTDIR="${D}" install
	doicon --size 256 ManPageEditor/resources/documenticons/256/maneditdoc.png
	doicon --size 128 ManPageEditor/resources/documenticons/128/maneditdoc.png
	doicon --size 48 ManPageEditor/resources/documenticons/48/maneditdoc.png
}
