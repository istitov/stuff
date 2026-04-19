# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="DKMS analog for gentoo"
HOMEPAGE="https://github.com/megabaks/dkms-gentoo"
SRC_URI="https://github.com/megabaks/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="sys-apps/openrc
		app-shells/bash
		sys-apps/gawk
		sys-apps/portage"
RDEPEND="${DEPEND}"

src_install(){
	dosbin dkms-gentoo/dkms-gentoo
	newinitd dkms-gentoo/dkms dkms

	dodir /var/lib/portage
	DKMS_DB="${D}/var/lib/portage/dkms_db" "${D}"/usr/sbin/dkms-gentoo --db
}

pkg_preinst() {
	# Preserve existing database across reinstalls.
	if [[ -f "${EROOT}/var/lib/portage/dkms_db" ]]; then
		cp "${EROOT}/var/lib/portage/dkms_db" \
			"${D}/var/lib/portage/dkms_db" || die
	fi
}

pkg_postinst() {
	[ ! -f /etc/runlevels/*/dkms ] && elog "Now you need run 'rc-update add dkms boot'"
}
