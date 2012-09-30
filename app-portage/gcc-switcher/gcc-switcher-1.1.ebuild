# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="Switch gcc's version per package"
HOMEPAGE="https://github.com/megabaks/gcc-switcher"
SRC_URI="https://github.com/downloads/megabaks/${PN}/${P}.tar.gz"

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

	if [ -f "${ROOT}/etc/portage/package.compilers" ];then
	  cp "${ROOT}/etc/portage/package.compilers" "${D}/etc/portage/package.compilers"
	else
	  insinto /etc/portage
	  doins "${FILESDIR}/package.compilers"
	fi

	if [ -f "${ROOT}/etc/portage/package.compilers-full" ];then
	  cp "${ROOT}/etc/portage/package.compilers-full" "${D}/etc/portage/package.compilers-full"
	else
	  insinto /etc/portage
	  doins "${FILESDIR}/package.compilers-full"
	fi
}
pkg_postinst() {
	if grep -q gcc-switcher "${ROOT}/etc/portage/bashrc";then
	  elog "Now you need run:\necho 'source /etc/portage/gcc-switcher' >> /etc/portage/bashrc"
	fi
}
