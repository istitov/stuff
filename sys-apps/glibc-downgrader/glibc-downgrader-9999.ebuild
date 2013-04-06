# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils git-2

DESCRIPTION="Script for downgrading sys-libs/glibc"
HOMEPAGE="https://github.com/megabaks/glibc-downgrader"
EGIT_REPO_URI="git://github.com/megabaks/${PN}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="app-shells/bash
		sys-apps/gawk
		sys-apps/portage"
RDEPEND="${DEPEND}"

src_install(){
	dosbin glibc-downgrader
}
