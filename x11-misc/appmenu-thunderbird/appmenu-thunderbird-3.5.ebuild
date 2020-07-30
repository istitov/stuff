# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

WANT_AUTOCONF="2.1"
EBZR_REPO_URI="lp:globalmenu-extension/3.5"
# Workaround Gentoo bug #446422.
EBZR_UPDATE_CMD="bzr pull --overwrite"

inherit autotools bzr mozextension

DESCRIPTION="Appmenu support for Thunderbird"
HOMEPAGE="https://code.launchpad.net/~extension-hackers/globalmenu-extension/3.5"
SRC_URI=""

LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS=""
IUSE="wifi"

DEPEND="|| ( mail-client/thunderbird mail-client/thunderbird-bin )
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
	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/thunderbird"
	xpi_install "${S}/dist/xpi-stage/globalmenu"

	$(has thunderbird-bin thunderbird-bin ) && \
	dosym "/usr/$(get_libdir)/thunderbird/extensions/globalmenu@ubuntu.com" "/opt/thunderbird/extensions/globalmenu@ubuntu.com"
}
