# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="Designed for remove broken kernels from /boot and source_dirs/modules_dirs"
HOMEPAGE="https://github.com/megabaks/kernel-cleaner"
EGIT_REPO_URI="https://github.com/megabaks/${PN}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="+parallel"

KCDEPEND="app-shells/bash:=
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
	default
}

src_install() {
	dosbin kernel-cleaner
	insinto /etc
	doins kernel-cleaner.conf
}
