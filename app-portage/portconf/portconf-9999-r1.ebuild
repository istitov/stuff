# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="/etc/portage cleaner"
HOMEPAGE="https://github.com/megabaks/portconf"
EGIT_REPO_URI="https://github.com/megabaks/${PN}.git"

LICENSE="GPL-3"
SLOT="0"

DEPEND="app-shells/bash
		sys-apps/portage"
RDEPEND="${DEPEND}
		app-portage/eix
		app-portage/portage-utils
		sys-apps/gawk
		app-text/agrep"

#S="${WORKDIR}"

src_install(){
	insinto /etc/
	newins portconf.conf portconf.conf
	dosbin portconf
}
