# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit eutils fdo-mime flag-o-matic

DESCRIPTION="Additional completion definitions for Zsh"
HOMEPAGE="https://github.com/zsh-users/zsh-completions"

if [[ ${PV} == *9999* ]]; then
	inherit git-2
	EGIT_REPO_URI="git://github.com/zsh-users/${PN}.git"
	EGIT_BRANCH="master"
	KEYWORDS=""
	S="${WORKDIR}/${PN}"
else
	SRC_URI="https://github.com/zsh-users/${PN}/archive/${PV}.zip -> ${P}.zip"
	KEYWORDS="~arm ~amd64 ~x86"
#	S="${WORKDIR}/${PN}"
fi

LICENSE="ZSH"
SLOT="0"

DEPEND=">=app-shells/zsh-4.3.5"
RDEPEND="${DEPEND}
!app-shells/zsh-completion"

src_install() {
	insinto /usr/share/zsh/site-functions
	doins src/_*
	dodoc README.md
}

pkg_postinst() {
	elog
	elog "If you happen to compile your functions, you may need to delete"
	elog "~/.zcompdump{,.zwc} and recompile to make zsh-completion available"
	elog "to your shell."
	elog
}
