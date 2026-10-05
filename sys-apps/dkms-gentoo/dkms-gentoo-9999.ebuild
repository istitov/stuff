# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit git-r3

DESCRIPTION="DKMS analog for gentoo"
HOMEPAGE="https://github.com/megabaks/dkms-gentoo"
EGIT_REPO_URI="https://github.com/megabaks/${PN}.git"

LICENSE="GPL-3"
SLOT="0"

RDEPEND="
	app-shells/bash
	sys-apps/gawk
	sys-apps/gentoo-functions
	sys-apps/openrc
	sys-apps/portage
"
DEPEND="${RDEPEND}"

src_prepare() {
	default
	sed -i '1s|#!/sbin/runscript|#!/sbin/openrc-run|' dkms-gentoo/dkms || die
	# Trunk sources isolated-functions.sh from /usr/lib*/portage/bin, which
	# portage no longer installs, so eend is undefined; use gentoo-functions.
	sed -i 's|^source /usr/lib\*/portage/bin/isolated-functions\.sh$|. /lib/gentoo/functions.sh|' \
		dkms-gentoo/dkms-gentoo || die
	grep -q '^\. /lib/gentoo/functions\.sh$' dkms-gentoo/dkms-gentoo ||
		die "dkms-gentoo no longer sources isolated-functions.sh; recheck"
}

src_install() {
	dosbin dkms-gentoo/dkms-gentoo
	newinitd dkms-gentoo/dkms dkms

	dodir /var/lib/portage
	DKMS_DB="${D}/var/lib/portage/dkms_db" "${D}"/usr/sbin/dkms-gentoo --db || die
	# The script ends its database run with an unchecked touch and eend 0.
	[[ -f ${D}/var/lib/portage/dkms_db ]] || die "dkms-gentoo --db did not create the database"
}

pkg_preinst() {
	# Keep the existing database across reinstalls.
	if [[ -f "${EROOT}/var/lib/portage/dkms_db" ]]; then
		cp "${EROOT}/var/lib/portage/dkms_db" \
			"${D}/var/lib/portage/dkms_db" || die
	fi
}

pkg_postinst() {
	[[ ! -f /etc/runlevels/*/dkms ]] && elog "Now you need run 'rc-update add dkms boot'"
}
