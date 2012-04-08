# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-voip/linphone/linphone-3.4.3-r1.ebuild,v 1.4 2011/11/06 12:47:49 grobian Exp $

EAPI="4"

inherit eutils autotools multilib versionator pax-utils

DESCRIPTION="Video softphone based on the SIP protocol"
HOMEPAGE="http://www.linphone.org/"
SRC_URI="mirror://nongnu/${PN}/$(get_version_component_range 1-2).x/sources/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc gtk ipv6 ncurses nls video srtp g729"

RDEPEND=">=media-libs/mediastreamer-2.7.3[video?,ipv6?]
	>=net-libs/libeXosip-3.0.2
	>=net-libs/libosip-3.0.0
	>=net-libs/ortp-0.16.3
	gtk? ( dev-libs/glib:2
		>=gnome-base/libglade-2.4.0:2.0
		>=x11-libs/gtk+-2.4.0:2 )
	g729? ( >=net-misc/bcg729-1.0.0 )
	ncurses? ( sys-libs/readline
		sys-libs/ncurses )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( app-text/sgmltools-lite )
	nls? ( dev-util/intltool
		sys-devel/gettext )"

IUSE_LINGUAS=" fr it de ja es pl cs nl sv pt_BR hu ru zh_CN"
IUSE="${IUSE} ${IUSE_LINGUAS// / linguas_}"

pkg_setup() {
	if ! use gtk && ! use ncurses ; then
		ewarn "gtk and ncurses are disabled."
		ewarn "At least one of these use flags are needed to get a front-end."
		ewarn "Only liblinphone is going to be installed."
	fi

	strip-linguas ${IUSE_LINGUAS}
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-nls.diff
	epatch "${FILESDIR}"/${P}-extlibs.diff

	# remove speex check, avoid bug when mediastreamer[-speex]
	sed -i -e '/SPEEX/d' configure.ac || die "patching configure.ac failed"

	# fix path to use lib64
	sed -i -e "s:lib\(/liblinphone\):$(get_libdir)\1:" configure.ac \
		|| die "patching configure.ac failed"

	# make sure to use host libtool version
	rm -f m4/libtool.m4 m4/lt*.m4 #282268
	eautoreconf
}

src_configure() {
	# strict: we don't want -Werror
	# external-ortp,external-mediastreamer: prefer external libs
	# truespeech: seems not used, TODO: ask in ml
	# rsvp: breaking the build (not maintained anymore) --disable = --enable
	# alsa, artsc and portaudio are used for bundled mediastreamer
	econf \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--docdir="${EPREFIX}/usr/share/doc/${PF}"
		--disable-strict \
		--enable-external-ortp \
		--enable-external-mediastreamer \
		--disable-truespeech \
		$(use_enable doc manual) \
		$(use_enable gtk gtk_ui) \
		$(use_enable ipv6) \
		$(use_enable ncurses console_ui) \
		$(use_enable nls) \
		$(use_enable video)
}

src_install() {
	emake DESTDIR="${D}" install
	find "${ED}" -name '*.la' -exec rm -f {} +

	dodoc AUTHORS BUGS ChangeLog NEWS README README.arm TODO

	pax-mark m "${ED}usr/bin/linphone"
}
