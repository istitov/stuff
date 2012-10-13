# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="/etc/portage manager"
HOMEPAGE="https://github.com/megabaks/portconf"
SRC_URI="https://github.com/downloads/megabaks/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-shells/bash
		sys-apps/portage"
RDEPEND="${DEPEND}
		app-portage/eix
		sys-apps/gawk"

S="${WORKDIR}"

src_install(){
	if [ -f "${ROOT}/etc/portconf.conf" ];then
		mkdir "${D}/etc"
		cp "${ROOT}/etc/portconf.conf" "${D}/etc/portconf.conf"
	else
	  insinto /etc/
	  doins "portconf.conf"
	fi
	dosbin portconf
}
