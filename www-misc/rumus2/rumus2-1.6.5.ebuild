# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-misc/rumus2/rumus2-1.6.5.ebuild,v 1 2011/10/15 00:13:35 megabaks Exp $

EAPI=3

inherit rpm

DESCRIPTION="Trade-platform fxclub.org"
HOMEPAGE="http://www.fxclub.org/tools_soft/"
SRC_URI="http://download.fxclub.org/Rumus2/FxClub/Rumus2.rpm -> rumus-${PV}.rpm"

LICENSE=""
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc64 ~sparc ~x86"
IUSE=""

DEPEND_COMMON="x11-libs/qt-webkit:4
			   x11-libs/qt-core:4
			   x11-libs/qt-gui:4"
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
}