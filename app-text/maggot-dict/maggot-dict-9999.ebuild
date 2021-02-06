# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=4

PYTHON_DEPEND="2:2.7 3:3.2"
SUPPORT_PYTHON_ABIS="1"
EGIT_HAS_SUBMODULES="y"

inherit git-r3

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
	sed 's|completions||g' -i Makefile
}

src_install() {
	emake DESTDIR="${D}" install
}

pkg_postinst() {
	elog "To enable command-line completion for ${PN}, run:"
	elog "  eselect bashcomp enable maggot-dict-cli"
	elog "to install locally, or"
	elog "  eselect bashcomp enable --global maggot-dict-cli"
	elog "to install system-wide."
}
