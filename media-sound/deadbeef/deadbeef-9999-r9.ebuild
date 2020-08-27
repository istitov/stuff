# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit xdg-utils gnome2-utils git-r3 eutils

EGIT_REPO_URI="https://github.com/Alexey-Yakovenko/deadbeef.git"
EGIT_BRANCH="master"

KEYWORDS=""

DESCRIPTION="foobar2k-like music player"
HOMEPAGE="http://deadbeef.sourceforge.net/"

LICENSE="GPL-2
	LGPL-2.1
	ZLIB
	psf? ( BSD XMAME )
	dumb? ( DUMB-0.9.3 )
	shn? ( shorten )"
SLOT="0"
IUSE="adplug aac alac alsa psf ape cdda cover cover-imlib2 dts dumb converter curl ffmpeg flac gme
	hotkeys lastfm m3u midi mms mp3 musepack nls notify nullout oss pulseaudio rpath mono2stereo pltbrowser
	shellexec shn sid sndfile src static supereq threads tta vorbis vtx wavpack zip gtk3 +gtk2 wma"

REQUIRED_USE="
	cover? ( curl )
	lastfm? ( curl )
	|| ( alsa oss pulseaudio nullout )"

LANGS="be bg bn ca cs da de el en-GB es et eu fa fi fr gl he hr hu id it ja kk km lt nl pl pt pt-BR ro ru si sk sl sr sr-Latn sv te tr ug uk vi zh-CN zh-TW"

for i in ${LANGS}; do
	IUSE="${IUSE} l10n_${i}"
done

RDEPEND="aac? ( media-libs/faad2 )
	adplug? ( media-libs/adplug )
	alsa? ( media-libs/alsa-lib )
	alac? ( media-libs/faad2 )
	cdda? ( >=dev-libs/libcdio-0.90 media-libs/libcddb )
	cover? ( media-libs/imlib2 )
	ffmpeg? ( !media-plugins/deadbeef-ffmpeg >=media-video/ffmpeg-1.0.7 )
	flac? ( media-libs/flac )
	gtk2? ( x11-libs/gtk+:2 x11-libs/gtkglext )
	gtk3? ( x11-libs/gtk+:3 )
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
	curl? ( net-misc/curl )"

DEPEND="
	dev-libs/jansson
	dev-util/intltool
	${RDEPEND}"

QA_TEXTRELS="usr/lib/deadbeef/ffap.so.0.0.0"

pkg_setup() {
	if use psf || use dumb || use shn && use static ; then
		die "ao/converter/dumb or shn plugins can't be builded statically"
	fi
}

src_prepare() {
	touch config.rpath
	sh autogen.sh

	if use midi ; then
		# set default gentoo path
		sed -e 's;/etc/timidity++/timidity-freepats.cfg;/usr/share/timidity/freepats/timidity.cfg;g' \
		-i "${S}/plugins/wildmidi/wildmidiplug.c"
	fi

	# remove unity trash
	#TODO epatch "${FILESDIR}/desktop-2.patch"

	for lang in ${LANGS};do
		for x in ${lang};do
			if ! use l10n_${x}; then
				sed -e "s|^${x}$||" -i "po/LINGUAS"
			fi
		done
	done
	eapply_user
}

src_configure() {
	my_config="--disable-portable
		--docdir=/usr/share/${PN}
		--disable-coreaudio
		$(use_enable aac)
		$(use_enable adplug)
		$(use_enable alac)
		$(use_enable alsa)
		$(use_enable ape ffap)
		$(use_enable cdda)
		$(use_enable converter)
		$(use_enable cover artwork)
		$(use_enable cover-imlib2 artwork-imlib2)
		$(use_enable curl vfs-curl)
		$(use_enable dts dca)
		$(use_enable dumb)
		$(use_enable ffmpeg)
		$(use_enable flac)
		$(use_enable gme)
		$(use_enable gtk2)
		$(use_enable gtk3)
		$(use_enable hotkeys)
		$(use_enable lastfm lfm)
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
		$(use_enable pltbrowser)
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
		$(use_enable zip vfs-zip)
		$(use_enable wma)"

	econf ${my_config}
}
pkg_preinst() {
	use l10n_pt-BR || rm -f "${D}/usr/share/deadbeef/help.pt_BR.txt"
	use l10n_ru || rm -f "${D}/usr/share/deadbeef/help.ru.txt"
	gnome2_icon_savelist
	gnome2_schemas_savelist
}

pkg_postinst() {
	if use midi ; then
		einfo "enable manually freepats support for timidity via"
		einfo "eselect timidity set --global freepats"
	fi
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
	gnome2_schemas_update
}
