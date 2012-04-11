# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-misc/rumus2/rumus2-1.6.5.ebuild,v 1 2011/10/15 00:13:35 megabaks Exp $

EAPI=3

inherit rpm

DESCRIPTION="FOREX trading and technical analis terminal"
HOMEPAGE="http://www.fxclub.org/tools_soft_rumus2/"
SRC_URI="http://download.fxclub.org/Rumus2/FxClub/Rumus2.rpm -> rumus-${PV}.rpm"

LICENSE="as-is"
SLOT="0"
KEYWORDS="-* ~x86"
IUSE=""

DEPEND_COMMON="x11-libs/qt-webkit:4
			   x11-libs/qt-core:4
			   x11-libs/qt-gui:4
			   amd64? ( app-emulation/emul-linux-x86-qtlibs )"
RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

src_unpack () {
	rpm_src_unpack ${A}
	cd "${WORKDIR}"
}

src_install() {
	cp -R "." "${D}"
	insinto /usr/share/applications
	doins usr/local/share/apps/rumus2/etc/rumus2.desktop
	dosym /usr/local/lib/rumus2/libNewsModule2.so /usr/local/lib/rumus2/libNewsModule.so
}
