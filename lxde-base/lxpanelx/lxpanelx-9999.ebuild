# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/lxde-base/lxpanel/lxpanel-0.5.8.ebuild,v 1.1 2011/08/03 09:19:57 hwoarang Exp $

EAPI="4"

inherit autotools eutils subversion

DESCRIPTION="lxpanel fork with improved taskbar"
HOMEPAGE="http://code.google.com/p/lxpanelx/"
ESVN_REPO_URI="http://${PN}.googlecode.com/svn/trunk/"

LICENSE="GPL-2"
KEYWORDS=""
SLOT="0"
IUSE="+alsa"
RESTRICT="test"  # bug 249598

RDEPEND="x11-libs/gtk+:2
	x11-libs/libXmu
	x11-libs/libXpm
	lxde-base/lxmenu-data
	lxde-base/menu-cache
	!lxde-base/lxpanel
	alsa? ( media-libs/alsa-lib )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext"
S="${WORKDIR}"
src_prepare() {
	eautoreconf
}

src_configure() {
	local plugins=all
	[[ ${CHOST} == *-interix* ]] && plugins=deskno,kbled,xkb

	econf $(use_enable alsa) --with-x --with-plugins=${plugins}
	# the gtk+ dep already pulls in libX11, so we might as well hardcode with-x
}

src_install () {
	emake DESTDIR="${D}" install
	dodoc AUTHORS ChangeLog README

	# Get rid of the .la files.
	find "${D}" -name '*.la' -delete
}

pkg_postinst() {
	elog "If you have problems with broken icons shown in the main panel,"
	elog "you will have to configure panel settings via its menu."
	elog "This will not be an issue with first time installations."
}
