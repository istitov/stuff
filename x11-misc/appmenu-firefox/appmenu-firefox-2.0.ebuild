# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

WANT_AUTOCONF="2.1"
EBZR_REPO_URI="lp:globalmenu-extension/2.0"

inherit autotools bzr mozextension

DESCRIPTION="Appmenu support for Firefox"
HOMEPAGE="https://code.launchpad.net/~extension-hackers/globalmenu-extension/2.0"
SRC_URI=""

LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~x86"
IUSE="wifi"

DEPEND="|| ( www-client/firefox www-client/firefox-bin )
		wifi? ( net-wireless/wireless-tools )"
RDEPEND="${DEPEND}"

src_unpack() {
	bzr_src_unpack
}

src_prepare() {
	eautoreconf || die "eautoreconf failed"
	sed -i 's/^ \t/\t/' "${S}/config/rules.mk"
	sed -i '/^XPIDL_COMPILE[[:space:]]*=/s@\$(LIBXUL_DIST)/@&sdk/@' \
		"${S}/config/config.mk"
}

src_configure() {
	econf \
		--with-libxul-sdk="${EPREFIX}"/usr/$(get_libdir)/firefox \
		--with-system-nspr \
		--enable-application=extensions \
		--enable-extensions=globalmenu \
		--disable-tests \
		$(use_enable wifi necko-wifi)
}

src_install() {
	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/firefox"
	xpi_install ${S}/dist/xpi-stage/globalmenu
}