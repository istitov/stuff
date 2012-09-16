# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils git-2

DESCRIPTION="Disigned for remove broken kernels from /boot and source_dirs/modules_dirs"
HOMEPAGE="https://github.com/megabaks/kernel-cleaner"
EGIT_REPO_URI="git://github.com/megabaks/${PN}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="virtual/linux-sources
		app-shells/bash
		sys-apps/gawk"
RDEPEND="${DEPEND}"

src_install(){
	dosbin kernel-cleaner
	insinto /etc
	doins kernel-cleaner.conf
}
