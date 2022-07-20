# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Designed for remove broken kernels from /boot and source_dirs/modules_dirs"
HOMEPAGE="https://github.com/megabaks/kernel-cleaner"
SRC_URI="https://github.com/megabaks/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+parallel"

KCDEPEND="app-shells/bash:=
	sys-apps/portage
	sys-apps/gawk"
DEPEND="${KCDEPEND}
	virtual/linux-sources"
RDEPEND="${KCDEPEND}
	parallel? ( sys-process/parallel )"

src_prepare(){
	if ! use parallel; then
		epatch no_parallel.patch
	fi
	default
}

src_install(){
	dosbin kernel-cleaner
	insinto /etc
	doins kernel-cleaner.conf
}
