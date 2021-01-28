# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit eutils git-r3

DESCRIPTION="DKMS analog for gentoo"
HOMEPAGE="https://github.com/megabaks/dkms-gentoo"
EGIT_REPO_URI="git://github.com/megabaks/${PN}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
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
