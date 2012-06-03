# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit fdo-mime gnome2-utils versionator

MY_PV="$(replace_version_separator 3 '-')"

SRC_URI="mirror://sourceforge/${PN}/${PN}-${MY_PV}.tar.bz2
		 http://sourceforge.net/projects/${PN}/files/${PN}-${MY_PV}.tar.bz2/download -> ${PN}-${MY_PV}.tar.bz2"
KEYWORDS="~x86 ~amd64"

DESCRIPTION="foobar2k-like music player"
HOMEPAGE="http://deadbeef.sourceforge.net/"

LICENSE="GPL-2
	LGPL-2.1
	ZLIB
	psf? ( BSD XMAME )
	dumb? ( DUMB-0.9.2 )
	shn? ( shorten )"
SLOT="0"
IUSE="adplug aac alsa psf ape cdda cover cover-imlib2 dts dumb converter curl ffmpeg flac gme
	hotkeys lastfm m3u midi mms mp3 musepack nls notify nullout oss pulseaudio rpath mono2stereo
	shellexec shn sid sndfile src static supereq threads tta vorbis vtx wavpack zip gtk3 +gtk2 infobar"

LANGS="be bg bn ca cs da de el en_GB es fa fi fr gl he hr hu id it ja kk km lg nb nl pl pt_BR pt ru si sk sl sr@latin sr sv te tr uk vi zh_CN zh_TW"
for lang in ${LANGS}; do
	IUSE+=" linguas_${lang}"
done

RDEPEND="aac? ( media-libs/faad2 )
	alsa? ( media-libs/alsa-lib )
	cdda? ( dev-libs/libcdio media-libs/libcddb )
	cover? ( media-libs/imlib2 net-misc/curl )
	ffmpeg? ( virtual/ffmpeg )
	flac? ( media-libs/flac )
	gtk2? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
	lastfm? ( net-misc/curl )
	notify? ( sys-apps/dbus )
	midi? ( media-sound/timidity-freepats )
	mms? ( media-libs/libmms )
	mp3? ( media-libs/libmad )
	musepack? ( media-sound/musepack-tools )
	pulseaudio? ( media-sound/pulseaudio )
	sndfile? ( media-libs/libsndfile )
	src? ( media-libs/libsamplerate )
	vorbis? ( media-libs/libvorbis )
	wavpack? ( media-sound/wavpack )
	zip? ( dev-libs/libzip
	sys-libs/zlib )
	curl? ( net-misc/curl )
	infobar? ( net-misc/curl )"

DEPEND="
	dev-util/intltool
	${RDEPEND}"
S="${WORKDIR}/${PN}-${MY_PV}"
pkg_setup() {
	if use psf || use dumb || use shn && use static ; then
		die "ao/converter/dumb or shn plugins can't be builded statically"
	fi
}

src_prepare() {
	if use midi ; then
		# set default gentoo path
		sed -e 's;/etc/timidity++/timidity-freepats.cfg;/usr/share/timidity/freepats/timidity.cfg;g' \
			-i "${S}/plugins/wildmidi/wildmidiplug.c"
	fi
	for lang in ${LANGS};do
	for x in ${lang};do
	  if ! use linguas_${x}; then
		rm -f "po/${x}.po"
	  fi
	done
	done
}

src_configure() {
	my_config="--disable-portable
		--docdir=/usr/share/${PN}
		$(use_enable aac)
		$(use_enable adplug)
		$(use_enable alsa)
		$(use_enable ape ffap)
		$(use_enable cdda)
		$(use_enable converter)
		$(use_enable dts dca)
		$(use_enable dumb)
		$(use_enable ffmpeg)
		$(use_enable flac)
		$(use_enable gme)
		$(use_enable hotkeys)
		$(use_enable m3u)
		$(use_enable midi wildmidi)
		$(use_enable mms)
		$(use_enable mono2stereo)
		$(use_enable mp3 mad)
		$(use_enable musepack)
		$(use_enable nls)
		$(use_enable notify)
		$(use_enable nullout)
		$(use_enable oss)
		$(use_enable psf)
		$(use_enable pulseaudio pulse)
		$(use_enable rpath)
		$(use_enable shellexec)
		$(use_enable shellexec shellexecui)
		$(use_enable shn)
		$(use_enable sid)
		$(use_enable sndfile)
		$(use_enable src)
		$(use_enable static)
		$(use_enable static staticlink)
		$(use_enable supereq)
		$(use_enable threads)
		$(use_enable tta)
		$(use_enable vorbis)
		$(use_enable vtx)
		$(use_enable wavpack)
		$(use_enable zip vfs-zip)"

	if use cover || use lastfm ; then
		my_config="${my_config}
			--enable-vfs-curl
			$(use_enable cover artwork)
			$(use_enable cover-imlib2 artwork-imlib2)
			$(use_enable lastfm lfm)"
	else
		my_config="${my_config}
			$(use_enable cover artwork)
			$(use_enable cover-imlib2 artwork-imlib2)
			$(use_enable curl vfs-curl)
			$(use_enable lastfm lfm)"
	fi

	if use infobar; then
	  my_config="${my_config}
	  --enable-vfs-curl"
	fi

	if use gtk3;then
	  my_config="${my_config}
	  --enable-gtk3
	  --enable-gtkui"
	fi

	if use gtk2;then
	  my_config="${my_config}
	  --enable-gtkui"
	else
	  my_config="${my_config}
	  --disable-gtk2"
	fi
	econf ${my_config}
}

pkg_preinst() {
	gnome2_icon_savelist
	gnome2_schemas_savelist
}

pkg_postinst() {
	if use midi ; then
		einfo "enable manually freepats support for timidity via"
		einfo "eselect timidity set --global freepats"
	fi
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
	gnome2_schemas_update
}
