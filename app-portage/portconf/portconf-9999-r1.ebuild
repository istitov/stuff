# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="/etc/portage cleaner"
HOMEPAGE="https://github.com/megabaks/portconf"
EGIT_REPO_URI="https://github.com/megabaks/${PN}.git"

LICENSE="GPL-3"
SLOT="0"

RDEPEND="
	app-portage/eix
	app-portage/portage-utils
	app-shells/bash:=
	dev-libs/tre
	sys-apps/gawk
	sys-apps/portage
"
DEPEND="${RDEPEND}"

src_install() {
	insinto /etc
	newins portconf.conf portconf.conf
	dosbin portconf
}
