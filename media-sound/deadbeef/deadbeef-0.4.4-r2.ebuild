# Copyright 2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit fdo-mime

DESCRIPTION="foobar2k-like music player"
HOMEPAGE="http://deadbeef.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-${PV}.tar.bz2"

LICENSE="GPL-2 ZLIB
	dumb? ( DUMB-0.9.2 )
	shorten? ( shorten )
	audiooverload? ( BSD XMAME )"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="+gtk gtk3 +alsa ffmpeg pulseaudio mp3 +vorbis +flac wavpack sndfile cdda +hotkeys
	oss lastfm adplug +ape sid nullout +supereq vtx gme dumb +notify cover curl
	shellexec musepack +tta dts aac midi mms shorten audiooverload nls rpath threads static"

RDEPEND="media-libs/libsamplerate
	gtk? ( x11-libs/gtk+:2 )
	alsa? ( media-libs/alsa-lib )
	ffmpeg? ( media-video/ffmpeg )
	pulseaudio? ( media-sound/pulseaudio )
	mp3? ( media-libs/libmad )
	vorbis? ( media-libs/libvorbis )
	flac? ( media-libs/flac )
	wavpack? ( media-sound/wavpack )
	sndfile? ( media-libs/libsndfile )
	cdda? ( dev-libs/libcdio media-libs/libcddb )
	lastfm? ( net-misc/curl )
	notify? ( sys-apps/dbus )
	musepack? ( media-sound/musepack-tools )
	midi? ( media-sound/timidity-freepats )
	aac? ( media-libs/faad2 )
	mms? ( media-libs/libmms )"

DEPEND="${RDEPEND}"

src_prepare() {
	if use midi ; then
		# set default gentoo path
		sed -e 's;/etc/timidity++/timidity-freepats.cfg;/usr/share/timidity/freepats/timidity.cfg;g' \
			-i "${S}/plugins/wildmidi/wildmidiplug.c"
	fi
}

src_configure() {
	my_config="--disable-dependency-tracking
		$(use_enable static)
		$(use_enable nls)
		$(use_enable rpath)
		$(use_enable threads)
		$(use_enable gtk3)
		$(use_enable gtk gtkui)
		$(use_enable alsa)
		$(use_enable ffmpeg)
		$(use_enable pulseaudio pulse)
		$(use_enable mp3 mad)
		$(use_enable vorbis)
		$(use_enable flac)
		$(use_enable wavpack)
		$(use_enable sndfile)
		$(use_enable cdda)
		$(use_enable hotkeys)
		$(use_enable oss)
		$(use_enable adplug)
		$(use_enable ape ffap)
		$(use_enable sid)
		$(use_enable nullout)
		$(use_enable supereq)
		$(use_enable vtx)
		$(use_enable gme)
		$(use_enable dumb)
		$(use_enable notify)
		$(use_enable musepack)
		$(use_enable tta)
		$(use_enable dts dca)
		$(use_enable midi wildmidi)
		$(use_enable aac)
		$(use_enable shorten shn)
		$(use_enable audiooverload ao)
		$(use_enable shellexec)"
	if use cover || use lastfm ; then
		my_config="${my_config}
			--enable-vfs-curl
			$(use_enable cover artwork)
			$(use_enable lastfm lfm)"
	else
		my_config="${my_config}
			$(use_enable curl vfs-curl)
			$(use_enable cover artwork)
			$(use_enable lastfm lfm)"
	fi
	econf ${my_config} || die
}

src_install() {
	emake DESTDIR="${D}" install || die
}

pkg_postinst() {
	if use midi ; then
		echo
		einfo "enable manually freepats support for timidity via"
		einfo "eselect timidity set --global freepats"
		ebeep
	fi
}
