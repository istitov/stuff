# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
VIM_VERSION="7.3"

inherit git-2 vim toolchain-funcs

DESCRIPTION="Qt powered vim GUI"
HOMEPAGE="https://code.google.com/p/vim-qt/"
EGIT_REPO_URI="git://gitorious.org/vim-qt/vim-qt.git
	https://gitorious.org/vim-qt/vim-qt.git"

LICENSE="vim"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="
!x11-misc/appmenu-qt"

src_configure() {
	cd "${S}/src" || die
	tc-export CXX
	econf --enable-gui=qt --with-vim-name=qtvim
}

src_compile() {
	cd "${S}/src" || die
	emake
}

src_install() {
	cd "${S}/src" || die
	dobin qtvim
}
