# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils git-2

DESCRIPTION="Additional completion definitions for Zsh"
HOMEPAGE="https://github.com/zsh-users/zsh-completions"
SRC_URI=""

LICENSE="ZSH"
SLOT="0"
KEYWORDS=""
IUSE="ack adb android attach bpython brew bundle cap colorex
	cpanm debuild dhcpcd ditz emulator fab gas geany gem
	git-flow github git-pulls heroku jmeter jmeter-plugins
	jonas knife lein lunar lunchy manage.py mvn pear
	pgsql_utils pip pkcon play port redis-cli rvm
	setup.py showoff smartmontools srm ssh-copy-id symfony
	task teamocil thor vagrant virtualbox vpnc zargs"

DEPEND=">=app-shells/zsh-4.3.5"
RDEPEND="${DEPEND}"

EGIT_REPO_URI="git://github.com/zsh-users/zsh-completions.git"
EGIT_BRANCH="master"

S="${WORKDIR}/${PN}"

src_install() {
	insinto /usr/share/zsh/site-functions
	use ack && doins src/_ack
	use adb && doins src/_adb
	use android && doins src/_android
	use attach && doins src/_attach
	use bpython && doins src/_bpython
	use brew && doins src/_brew
	use bundle && doins src/_bundle
	use cap && doins src/_cap
	use cpanm && doins src/_cpanm
	use debuild && doins src/_debuild
	use dhcpcd && doins src/_dhcpcd
	use ditz && doins src/_ditz
	use emulator && doins src/_emulator
	use fab && doins src/_fab
	use gas && doins src/_gas
	use geany && doins src/_geany
	use gem && doins src/_gem
	use git-flow && doins src/_git-flow
	use github && doins src/_github
	use git-pulls && doins src/_git-pulls
	use heroku && doins src/_heroku
	use jmeter && doins src/_jmeter
	use jmeter-plugins && doins src/_jmeter-plugins
	use jonas && doins src/_jonas
	use knife && doins src/_knife
	use lein && doins src/_lein
	use lunar && doins src/_lunar
	use lunchy && doins src/_lunchy
	use manage.py && doins src/_manage.py
	use mvn && doins src/_mvn
	use pear && doins src/_pear
	use pgsql_utils && doins src/_pgsql_utils
	use pip && doins src/_pip
	use pkcon && doins src/_pkcon
	use play && doins src/_play
	use port && doins src/_port
	use redis-cli && doins src/_redis-cli
	use rvm && doins src/_rvm
	use setup.py && doins src/_setup.py
	use showoff && doins src/_showoff
	use smartmontools && doins src/_smartmontools
	use srm && doins src/_srm
	use ssh-copy-id && doins src/_ssh-copy-id
	use symfony && doins src/_symfony
	use teamocil && doins src/_teamocil
	use thor && doins src/_thor
	use vagrant && doins src/_vagrant
	use virtualbox && doins src/_virtualbox
	use vpnc && doins src/_vpnc

	dodoc README.md
}

pkg_postinst() {
	elog
	elog "If you happen to compile your functions, you may need to delete"
	elog "~/.zcompdump{,.zwc} and recompile to make zsh-completion available"
	elog "to your shell."
	elog
}
