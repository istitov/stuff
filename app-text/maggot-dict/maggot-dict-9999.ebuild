# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

PYTHON_DEPEND="2:2.7 3:3.2"
SUPPORT_PYTHON_ABIS="1"
EGIT_HAS_SUBMODULES="y"

inherit git-2

DESCRIPTION="Console based dictionary writen in pure Python"
HOMEPAGE="https://github.com/aslpavel/maggot-dict"
EGIT_REPO_URI="https://github.com/aslpavel/maggot-dict.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} app-shells/bash-completion"

src_prepare() {
	git submodule update --init --recursive
}

src_install() {
	emake DESTDIR="${D}" install
}
