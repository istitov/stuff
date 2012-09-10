# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="DKMS analog for gentoo"
HOMEPAGE="https://github.com/megabaks/dkms-gentoo"
SRC_URI="https://github.com/megabaks/test/raw/master/distfiles/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-apps/openrc
		app-shells/bash
		sys-apps/gawk
		sys-apps/portage"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_install(){
	dosbin dkms-gentoo
	newinitd dkms dkms

	if ! [ -f "${ROOT}/var/lib/portage/dkms_db" ];then
	dodir "/var/lib/portage/"
	DKMS_DB="${D}/var/lib/portage/dkms_db" "${D}"/usr/sbin/dkms-gentoo --db
	fi
}

pkg_postinst() {
	[ ! -f /etc/runlevels/*/dkms ] && elog "Now you need run 'rc-update add dkms boot'"
}
