# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils git-2

DESCRIPTION="/etc/portage cleaner"
HOMEPAGE="https://github.com/megabaks/portconf"
EGIT_REPO_URI="git://github.com/megabaks/${PN}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="app-shells/bash
		sys-apps/portage"
RDEPEND="${DEPEND}
		sys-apps/gawk"

S="${WORKDIR}"

src_install(){
	dosbin *
}
