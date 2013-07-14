# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="Designed for remove broken kernels from /boot and source_dirs/modules_dirs"
HOMEPAGE="https://github.com/megabaks/kernel-cleaner"
SRC_URI="https://github.com/megabaks/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="+parallel"

DEPEND="virtual/linux-sources
		app-shells/bash
		sys-apps/portage
		sys-apps/gawk"
RDEPEND="${DEPEND}
	parallel? ( sys-process/parallel )"

src_prepare(){
	if ! use parallel;then
	  epatch no_parallel.patch
	fi
}
src_install(){
	dosbin kernel-cleaner
	insinto /etc
	doins kernel-cleaner.conf
}
