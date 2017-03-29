# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit git-2 eutils

IUSE="tk"

DESCRIPTION="Tool for launching commands on keystrokes"
EGIT_REPO_URI="http://git.savannah.gnu.org/cgit/xbindkeys.git"
EGIT_BRANCH="master"
HOMEPAGE="http://www.nongnu.org/xbindkeys/xbindkeys.html"
S="${WORKDIR}/${PN}"

LICENSE="GPL-2"
KEYWORDS=""
SLOT="0"

RDEPEND="x11-libs/libX11
	>=dev-scheme/guile-1.8.4[deprecated]
	tk? ( dev-lang/tk )"
DEPEND="${RDEPEND}
	x11-proto/xproto"

src_configure() {
	local myconf
	use tk || myconf="${myconf} --disable-tk"

	econf ${myconf} || die "configure failed"
}

src_compile() {
	emake DESTDIR="${D}" || die "make failed"
}

src_install() {
	make DESTDIR="${D}" BINDIR=/usr/bin install || die "make install failed"
}
