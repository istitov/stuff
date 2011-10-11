# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpd/mpd-9999.ebuild,v 1.2 2011/07/17 16:08:37 angelos Exp $

EAPI=4
inherit autotools eutils flag-o-matic linux-info multilib git-2

DESCRIPTION="The Music Player Daemon (mpd)"
HOMEPAGE="http://www.musicpd.org"
EGIT_REPO_URI="git://git.musicpd.org/master/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="aac +alsa ao audiofile bzip2 cdio cue +curl debug +fifo +ffmpeg flac
fluidsynth profile +id3tag inotify ipv6 jack lame lastfmradio libsamplerate
+mad mikmod modplug mpg123 mms musepack +network ogg openal oss pipe pulseaudio
sid sndfile sqlite tcpd twolame unicode vorbis wavpack wildmidi zeroconf zip"

REQUIRED_USE="|| ( alsa ao fifo jack network openal oss pipe pulseaudio )
	|| ( aac audiofile ffmpeg flac fluidsynth mad mikmod modplug mpg123 musepack
			ogg flac sid vorbis wavpack wildmidi )
	network? ( || ( audiofile flac lame twolame vorbis ) )
	lastfmradio? ( curl )"

RDEPEND="!<sys-cluster/mpich2-1.4_rc2
	dev-libs/glib:2
	aac? ( media-libs/faad2 )
	alsa? ( media-sound/alsa-utils )
	ao? ( media-libs/libao[alsa?,pulseaudio?] )
	audiofile? ( media-libs/audiofile )
	bzip2? ( app-arch/bzip2 )
	cdio? ( dev-libs/libcdio
		virtual/cdrtools )
	cue? ( media-libs/libcue )
	curl? ( net-misc/curl )
	ffmpeg? ( virtual/ffmpeg )
	flac? ( media-libs/flac[ogg?] )
	fluidsynth? ( media-sound/fluidsynth )
	network? ( >=media-libs/libshout-2 )
	id3tag? ( media-libs/libid3tag )
	jack? ( media-sound/jack-audio-connection-kit )
	lame? ( network? ( media-sound/lame ) )
	libsamplerate? ( media-libs/libsamplerate )
	mad? ( media-libs/libmad )
	mikmod? ( media-libs/libmikmod )
	mms? ( media-libs/libmms )
	modplug? ( media-libs/libmodplug )
	mpg123? ( >=media-sound/mpg123-1.12.2 )
	musepack? ( media-sound/musepack-tools )
	ogg? ( media-libs/libogg )
	openal? ( media-libs/openal )
	pulseaudio? ( media-sound/pulseaudio )
	sid? ( media-libs/libsidplay:2 )
	sndfile? ( media-libs/libsndfile )
	sqlite? ( dev-db/sqlite:3 )
	tcpd? ( sys-apps/tcp-wrappers )
	twolame? ( media-sound/twolame )
	vorbis? ( media-libs/libvorbis )
	wavpack? ( media-sound/wavpack )
	wildmidi? ( media-sound/wildmidi )
	zeroconf? ( net-dns/avahi[dbus] )
	zip? ( dev-libs/zziplib )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

pkg_setup() {
	use network || ewarn "Icecast and Shoutcast streaming needs networking."
	use fluidsynth && ewarn "Using fluidsynth is discouraged by upstream."

	enewuser mpd "" "" "/var/lib/mpd" audio

	if use inotify; then
		CONFIG_CHECK="~INOTIFY_USER"
		ERROR_INOTIFY_USER="${P} requires inotify in-kernel support."
		linux-info_pkg_setup
	fi
}

src_prepare() {
	cp -f doc/mpdconf.example doc/mpdconf.dist || die "cp failed"
	epatch "${FILESDIR}"/${PN}-0.16.conf.patch
	epatch "${FILESDIR}"/mpd_shorter.patch
	eautoreconf
}

src_configure() {
	local mpdconf="--disable-despotify --disable-documentation --disable-ffado
		--disable-gme --disable-mvp --disable-roar --enable-largefile
		--enable-raop-output --enable-recorder-output --enable-tcp --enable-un
		--docdir=${EPREFIX}/usr/share/doc/${PF}"

	if use network; then
		mpdconf+=" --enable-shout $(use_enable vorbis vorbis-encoder)
			--enable-httpd-output $(use_enable lame lame-encoder)
			$(use_enable twolame twolame-encoder)
			$(use_enable audiofile wave-encoder)"
	else
		mpdconf+=" --disable-shout --disable-vorbis-encoder
			--disable-httpd-output --disable-lame-encoder
			--disable-twolame-encoder --disable-wave-encoder"
	fi

	if use flac && use ogg; then
		mpdconf+=" --enable-oggflac"
	else
		mpdconf+=" --disable-oggflac"
	fi

	append-lfs-flags
	append-ldflags "-L/usr/$(get_libdir)/sidplay/builders"

	econf \
		$(use_enable aac) \
		$(use_enable alsa) \
		$(use_enable ao) \
		$(use_enable audiofile) \
		$(use_enable bzip2) \
		$(use_enable cdio iso9660) \
		$(use_enable cdio cdio-paranoia) \
		$(use_enable cue) \
		$(use_enable curl) \
		$(use_enable debug) \
		$(use_enable ffmpeg) \
		$(use_enable fifo) \
		$(use_enable flac) \
		$(use_enable fluidsynth) \
		$(use_enable id3tag id3) \
		$(use_enable inotify) \
		$(use_enable ipv6) \
		$(use_enable jack) \
		$(use_enable lastfmradio lastfm) \
		$(use_enable libsamplerate lsr) \
		$(use_enable mad) \
		$(use_enable mikmod) \
		$(use_enable mms) \
		$(use_enable modplug) \
		$(use_enable mpg123) \
		$(use_enable musepack mpc) \
		$(use_enable openal) \
		$(use_enable oss) \
		$(use_enable pipe pipe-output) \
		$(use_enable profile gprof) \
		$(use_enable pulseaudio pulse) \
		$(use_enable sid sidplay) \
		$(use_enable sndfile) \
		$(use_enable sqlite) \
		$(use_enable tcpd libwrap) \
		$(use_enable vorbis) \
		$(use_enable wavpack) \
		$(use_enable wildmidi) \
		$(use_enable zip zzip) \
		$(use_with zeroconf zeroconf avahi) \
		${mpdconf}
}

src_install() {
	emake DESTDIR="${D}" install

	insinto /etc
	newins doc/mpdconf.dist mpd.conf

	newinitd "${FILESDIR}"/mpd.init mpd

	if use unicode; then
		sed -i -e 's:^#filesystem_charset.*$:filesystem_charset "UTF-8":' \
			"${D}"/etc/mpd.conf || die "sed failed"
	fi

	diropts -m0755 -o mpd -g audio
	dodir /var/lib/mpd
	keepdir /var/lib/mpd
	dodir /var/lib/mpd/music
	keepdir /var/lib/mpd/music
	dodir /var/lib/mpd/playlists
	keepdir /var/lib/mpd/playlists
}

pkg_postinst() {
	elog "If you will be starting mpd via /etc/init.d/mpd, please make"
	elog "sure that MPD's pid_file is unset."

	# also change the homedir if the user has existed before
	usermod -d "/var/lib/mpd" mpd
}
