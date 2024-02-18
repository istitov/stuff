# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

IUSE="guile tk"

DESCRIPTION="Tool for launching commands on keystrokes"
EGIT_REPO_URI="https://git.savannah.gnu.org/git/xbindkeys.git"
EGIT_BRANCH="master"
HOMEPAGE="http://www.nongnu.org/xbindkeys/xbindkeys.html"

LICENSE="GPL-2"
SLOT="0"

RDEPEND="x11-libs/libX11
	guile? ( >=dev-scheme/guile-1.8.4[deprecated] )
	tk? ( dev-lang/tk:0 )"
DEPEND="${RDEPEND}
	x11-base/xorg-proto"

S="${WORKDIR}/${P}"

src_configure() {
	econf \
		$(use_enable tk) \
		$(use_enable guile) || die "configure failed"
}

src_compile() {
	emake DESTDIR="${D}" || die "make failed"
}

src_install() {
	make DESTDIR="${D}" BINDIR=/usr/bin install || die "make install failed"
}
