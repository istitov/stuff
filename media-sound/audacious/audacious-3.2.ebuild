# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/audacious/audacious-3.1.ebuild,v 1.3 2011/11/15 18:27:46 jer Exp $

EAPI=4

MY_P="${P/_/-}"
S="${WORKDIR}/${MY_P}"
DESCRIPTION="Audacious Player - Your music, your way, no exceptions"
HOMEPAGE="http://audacious-media-player.org/"
SRC_URI="http://distfiles.audacious-media-player.org/${MY_P}.tar.bz2
	 mirror://gentoo/gentoo_ice-xmms-0.2.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 hppa ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="chardet nls session gtk3"
LANGS="ast be bg br ca cs cy de el es_AR es_MX es et eu fi fr hi hr hu it ja ka ko lt lv mk nl pl pt_BR 
pt_PT ro ru sk sl sr@Latn sr sv tr uk vi zh_CN zh_TW"
for lang in ${LANGS}; do
	IUSE+=" linguas_${lang}"
done

RDEPEND=">=dev-libs/dbus-glib-0.60
	>=dev-libs/glib-2.16
	>=dev-libs/libmcs-0.7.1-r2
	>=dev-libs/libmowgli-0.9.50
	dev-libs/libxml2
	>=x11-libs/cairo-1.2.6
	>=x11-libs/pango-1.8.0
	|| ( gtk3? ( x11-libs/gtk+:3 ) x11-libs/gtk+:2 )
	session? ( x11-libs/libSM )"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9.0
	chardet? ( app-i18n/libguess )
	nls? ( dev-util/intltool )"

PDEPEND=">=media-plugins/audacious-plugins-3.1"

src_configure() {
	# D-Bus is a mandatory dependency, remote control,
	# session management and some plugins depend on this.
	# Building without D-Bus is *unsupported* and a USE-flag
	# will not be added due to the bug reports that will result.
	# Bugs #197894, #199069, #207330, #208606
	# Use of GTK+2 causes plugin build failures, bug #384185
	econf \
		--enable-dbus \
		$(use_enable gtk3) \
		$(use_enable chardet) \
		$(use_enable nls) \
		$(use_enable session sm)
}

src_install() {
	default
	dodoc AUTHORS README

	# Gentoo_ice skin installation; bug #109772
	insinto /usr/share/audacious/Skins/gentoo_ice
	doins "${WORKDIR}"/gentoo_ice/*
	docinto gentoo_ice
	dodoc "${WORKDIR}"/README

  for lang in ${LANGS};do
	for x in ${lang};do
	  if ! use linguas_${x}; then
		rm -f "${D}usr/share/locale/${x}/LC_MESSAGES/audacious.mo"
	  fi
	done
  done
}
