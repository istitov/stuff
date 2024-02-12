# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="quick set opts per package"
HOMEPAGE="https://github.com/megabaks/portopts"
EGIT_REPO_URI="https://github.com/megabaks/${PN}.git"

LICENSE="GPL-3"
SLOT="0"

DEPEND="app-shells/bash:=
		sys-apps/portage"
RDEPEND="${DEPEND}
		sys-apps/gawk"

S="${WORKDIR}"

src_install(){
	dosbin *
}
