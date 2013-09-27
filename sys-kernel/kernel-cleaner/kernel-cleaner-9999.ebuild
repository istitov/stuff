# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils git-2

DESCRIPTION="Designed for remove broken kernels from /boot and source_dirs/modules_dirs"
HOMEPAGE="https://github.com/megabaks/kernel-cleaner"
EGIT_REPO_URI="git://github.com/megabaks/${PN}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="+parallel"

KCDEPEND="app-shells/bash
	sys-apps/portage
	sys-apps/gawk"
DEPEND="${KCDEPEND}
	virtual/linux-sources"
RDEPEND="${KCDEPEND}
	parallel? ( sys-process/parallel )"

src_prepare() {
	if ! use parallel;then
		epatch no_parallel.patch
	fi
}

src_install() {
	dosbin kernel-cleaner
	insinto /etc
	doins kernel-cleaner.conf
}
