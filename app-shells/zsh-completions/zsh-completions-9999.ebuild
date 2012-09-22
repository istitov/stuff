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
	use ack && doins _ack
	use adb && doins _adb
	use android && doins _android
	use attach && doins _attach
	use bpython && doins _bpython
	use brew && doins _brew
	use bundle && doins _bundle
	use cap && doins _cap
	use colorex && doins _colorex
	use cpanm && doins _cpanm
	use debuild && doins _debuild
	use dhcpcd && doins _dhcpcd
	use ditz && doins _ditz
	use emulator && doins _emulator
	use fab && doins _fab
	use gas && doins _gas
	use geany && doins _geany
	use gem && doins _gem
	use git-flow && doins _git-flow
	use github && doins _github
	use git-pulls && doins _git-pulls
	use heroku && doins _heroku
	use jmeter && doins _jmeter
	use jmeter-plugins && doins _jmeter-plugins
	use jonas && doins _jonas
	use knife && doins _knife
	use lein && doins _lein
	use lunar && doins _lunar
	use lunchy && doins _lunchy
	use manage.py && doins _manage.py
	use mvn && doins _mvn
	use pear && doins _pear
	use pgsql_utils && doins _pgsql_utils
	use pip && doins _pip
	use pkcon && doins _pkcon
	use play && doins _play
	use port && doins _port
	use redis-cli && doins _redis-cli
	use rvm && doins _rvm
	use setup.py && doins _setup.py
	use showoff && doins _showoff
	use smartmontools && doins _smartmontools
	use srm && doins _srm
	use ssh-copy-id && doins _ssh-copy-id
	use symfony && doins _symfony
	use task && doins _task
	use teamocil && doins _teamocil
	use thor && doins _thor
	use vagrant && doins _vagrant
	use virtualbox && doins _virtualbox
	use vpnc && doins _vpnc
	use zargs && doins _zargs

	dodoc AUTHORS
}

pkg_postinst() {
	elog
	elog "If you happen to compile your functions, you may need to delete"
	elog "~/.zcompdump{,.zwc} and recompile to make zsh-completion available"
	elog "to your shell."
	elog
}
