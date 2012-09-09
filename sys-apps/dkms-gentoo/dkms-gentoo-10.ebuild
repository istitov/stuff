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

DEPEND="sys-apps/openrc"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_install(){
	dosbin dkms-gentoo
	newinitd dkms dkms
}

pkg_postinst() {
	elog "Now you need run 'dkms-gentoo --db'"
}
