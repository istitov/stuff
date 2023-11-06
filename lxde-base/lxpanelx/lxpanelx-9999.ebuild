# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools unpacker

DESCRIPTION="lxpanel fork with improved taskbar"
HOMEPAGE="https://code.google.com/p/lxpanelx/"
SRC_URI="https://storage.googleapis.com/google-code-archive-source/v2/code.google.com/lxpanelx/source-archive.zip"
#ESVN_REPO_URI="https://${PN}.googlecode.com/svn/trunk/"

LICENSE="GPL-2"
KEYWORDS=""
SLOT="0"
IUSE="+alsa oss plugins libfm libindicator menucache"
RESTRICT="test"  # bug 249598

RDEPEND="x11-libs/gtk+:2
	x11-libs/libXmu
	x11-libs/libXpm
	lxde-base/lxmenu-data
	x11-libs/gdk-pixbuf-xlib
	!lxde-base/lxpanel
	alsa? ( media-libs/alsa-lib )
	libindicator? ( dev-libs/libindicator:0 )
	libfm? ( x11-libs/libfm )
	menucache? ( lxde-base/menu-cache )"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	sys-devel/gettext"

S="${WORKDIR}/${PN}/trunk"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	if use plugins;then
		all="taskbar,netstatus,volume,volumealsa,cpu,deskno,batt,kbled,xkb,thermal,cpufreq"
		local plugins="${all}"
		[[ ${CHOST} == *-interix* ]] && plugins="deskno,kbled,xkb"
		if ! use alsa;then
			plugins="${plugins/,volumealsa/}"
		fi
		if ! use oss;then
			plugins="${plugins/,volume/}"
		fi
		myconf="${plugins}"
	else
		use alsa && myconf+="volumealsa,"
		use oss && myconf+="volume,"
		if ! use alsa && ! use oss;then
			myconf="none"
		fi
	fi

	econf \
		--with-x \
		--disable-dependency-tracking \
		--enable-silent-rules \
		--with-plugins=${myconf%,} \
		$(use_enable alsa) \
		$(use_with libfm) \
		$(use_enable libindicator indicator-support)
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
