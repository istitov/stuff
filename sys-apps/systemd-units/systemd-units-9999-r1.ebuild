# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit eutils systemd

DESCRIPTION="Service files for sys-apps/systemd"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/systemd http://en.gentoo-wiki.com/wiki/Systemd"
SRC_URI="basic? ( http://0pointer.de/public/systemd-units/sshd.service
	http://0pointer.de/public/systemd-units/sshd.socket
	http://0pointer.de/public/systemd-units/sshd@.service )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="+basic +desktop server ingnome3"

RDEPEND=""
DEPEND=""

src_install() {
	if use basic; then
		systemd_dounit "${FILESDIR}"/services-basic/*
	fi

	if use server; then
		systemd_dounit "${FILESDIR}"/services-server/*
		systemd_dotmpfilesd "${FILESDIR}"/tmpfiles-server/*
	fi

	if use desktop; then
		systemd_dounit "${FILESDIR}"/services-desktop/*

		if ! use ingnome3; then
			rm -f "${D}/$(systemd_get_unitdir)"/gdm@.service
		fi
	fi
}
