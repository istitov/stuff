# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="/etc/portage cleaner"
HOMEPAGE="https://github.com/megabaks/portconf"
SRC_URI="https://github.com/megabaks/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE=""
RESTRICT="mirror"

DEPEND="app-shells/bash
		sys-apps/portage"
RDEPEND="${DEPEND}
		app-portage/eix
		app-portage/portage-utils
		sys-apps/gawk
		app-text/agrep"

src_install(){
	insinto /etc/
	newins portconf.conf portconf.conf
	dosbin portconf
}
