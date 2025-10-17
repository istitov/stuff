# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_REPO_URI="https://github.com/pasis/ipx-utils.git"

inherit autotools git-r3

DESCRIPTION="The IPX Utilities"
HOMEPAGE="https://github.com/pasis/ipx-utils"

LICENSE="ipx-utils GPL-2" # GPL-2 only for init script
SLOT="0"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf --bindir="${EPREFIX}"/sbin
}

src_install() {
	newconfd "${FILESDIR}"/ipx.confd ipx
	newinitd "${FILESDIR}"/ipx.init ipx
	default
}

pkg_postinst() {
	elog "IPX support was removed in Linux 4.18. For newer kernels build the ipx module from sources: https://github.com/pasis/ipx"
}
