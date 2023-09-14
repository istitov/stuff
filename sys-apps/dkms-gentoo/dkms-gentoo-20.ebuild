# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

DESCRIPTION="DKMS analog for gentoo"
HOMEPAGE="https://github.com/megabaks/dkms-gentoo"
SRC_URI="https://github.com/megabaks/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-apps/openrc
		app-shells/bash
		sys-apps/gawk
		sys-apps/portage"
RDEPEND="${DEPEND}"

src_install(){
	dosbin dkms-gentoo/dkms-gentoo
	newinitd dkms-gentoo/dkms dkms

	if ! [ -f "${ROOT}/var/lib/portage/dkms_db" ];then
	  dodir "/var/lib/portage/"
	  DKMS_DB="${D}/var/lib/portage/dkms_db" "${D}"/usr/sbin/dkms-gentoo --db
	else
	  dodir "/var/lib/portage/"
	  cp "${ROOT}/var/lib/portage/dkms_db" "${D}/var/lib/portage/dkms_db"
	fi
}

pkg_postinst() {
	[ ! -f /etc/runlevels/*/dkms ] && elog "Now you need run 'rc-update add dkms boot'"
}
