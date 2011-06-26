# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/smart-live-rebuild/smart-live-rebuild-1.0.ebuild,v 1.1 2011/06/25 13:05:45 mgorny Exp $

EAPI=3
PYTHON_DEPEND='*:2.6'
SUPPORT_PYTHON_ABIS=1
RESTRICT_PYTHON_ABIS='2.4 2.5'
inherit distutils

DESCRIPTION="Check live packages for updates and emerge them as necessary"
HOMEPAGE="https://github.com/mgorny/smart-live-rebuild/"
SRC_URI="http://cloud.github.com/downloads/mgorny/${PN}/${P}.tar.bz2"

LICENSE="|| ( BSD GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=sys-apps/portage-2.1.8.3"

PYTHON_MODNAME=smartliverebuild

src_install() {
	distutils_src_install

	insinto /etc/portage
	newins smart-live-rebuild.conf{.example,} || die
	insinto /usr/share/portage/config/sets
	newins sets.conf.example ${PN}.conf || die
}
