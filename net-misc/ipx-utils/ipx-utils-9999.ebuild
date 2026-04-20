# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3

DESCRIPTION="The IPX Utilities"
HOMEPAGE="https://github.com/pasis/ipx-utils"
EGIT_REPO_URI="https://github.com/pasis/${PN}.git"

# GPL-2 only for the init script
LICENSE="ipx-utils GPL-2"
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
