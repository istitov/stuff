# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="Switch gcc's version per package"
HOMEPAGE="https://github.com/megabaks/stuff"
SRC_URI="https://github.com/megabaks/test/raw/master/distfiles/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-shells/bash
		sys-apps/portage"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_install(){
	insinto /etc/portage
	doins gcc-switcher
}
pkg_postinst() {
  grep -q gcc-switcher "${ROOT}/etc/portage/bashrc" || elog "Now you need run:\necho 'source /etc/portage/gcc-switcher' >> /etc/portage/bashrc"
}