# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools desktop git-r3 xdg

DESCRIPTION="Man Page Editor"
HOMEPAGE="https://github.com/KeithDHedger/ManPageEditor"
EGIT_REPO_URI="https://github.com/KeithDHedger/ManPageEditor.git"

LICENSE="GPL-3"
SLOT="0"
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
