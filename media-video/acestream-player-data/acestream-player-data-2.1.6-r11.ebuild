# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit multilib unpacker toolchain-funcs

DESCRIPTION="ACE Stream player libraries files"
HOMEPAGE="http://torrentstream.org/"
SRC_URI=" x86? ( http://repo.acestream.org/ubuntu/pool/main/a/${PN}/${PN}_${PV}-1raring2_i386.deb
				 http://stuff.tazhate.com/distfiles/${PN}_${PV}-1raring2_i386.deb )
		amd64? ( http://repo.acestream.org/ubuntu/pool/main/a/${PN}/${PN}_${PV}-1raring2_amd64.deb
				 http://stuff.tazhate.com/distfiles/${PN}_${PV}-1raring2_amd64.deb )"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="pulseaudio jack portaudio avahi cddb cdda dvd flac lirc mad matroska modplug musepack mpeg
		ieee1394 samba mtp ncurses libproxy speex upnp v4l vcdx"
#aac dropped due to ffmpeg
LANGS="ach af am ar ast be bg bn br ca cs da de el en-GB es et eu fa ff fi fr ga gl he
		hi hr hu hy id is it ja ka kk km ko lt lv mk ml mn ms my nb ne nl nn oc pa pl pt-BR pt-PT
		ro ru si sk sl sq sr sv ta th tl tr uk vi zh-CN zh-TW zu"
#wa

for lang in ${LANGS}; do
	IUSE+=" l10n_${lang}"
done

CDEPEND=""
DEPEND="media-libs/aalib
		media-libs/libass
		x11-libs/libdrm
		media-libs/taglib
		media-libs/xvid
		media-libs/x264
		media-libs/acestream-x264
		net-libs/gnutls
		media-libs/libvpx
		media-libs/vo-aacenc
		media-sound/lame
		media-libs/faac
		dev-lang/orc
		media-libs/libggi
		media-libs/libgii
		>=dev-lang/lua-5.1
		media-libs/libshout[speex=,theora]
		media-libs/libpng
		media-libs/alsa-lib
		media-libs/libcaca
		dev-libs/openssl:0
		>=dev-libs/libebml-1.3.0
		>=media-libs/a52dec-0.7.4
		media-video/ffmpeg
		|| ( media-video/acestream-ffmpeg[pulseaudio=,jack=,modplug=,ieee1394=,speex=,theora,v4l=,vaapi,vorbis,alsa]
			 media-video/ffmpeg[pulseaudio=,jack=,modplug=,ieee1394=,speex=,theora,v4l=,vorbis,alsa] )
		sys-apps/dbus
		media-video/dirac
		media-libs/libdvbpsi
		media-libs/libogg
		dev-libs/fribidi
		|| ( <dev-libs/libgcrypt-1.6.0 dev-libs/acestream-libgcrypt )
		dev-libs/libgpg-error
		media-libs/mesa
		dev-qt/qtwebkit
		dev-qt/qtdeclarative
		media-libs/libsdl
		media-libs/sdl-image
		media-libs/libtheora
		x11-libs/libva
		media-libs/libvorbis
		dev-libs/libxml2
		x11-libs/libXpm
		musepack? ( media-sound/musepack-tools )
		modplug? ( media-libs/libmodplug )
		matroska? ( media-libs/libmatroska dev-libs/acestream-libebml media-libs/libmkv )
		vcdx? ( dev-libs/libcdio media-video/vcdimager )
		ieee1394? ( sys-libs/libraw1394 sys-libs/libavc1394 media-libs/libdc1394 )
		mad? ( media-libs/libmad )
		mpeg? ( media-libs/libmpeg2 media-sound/twolame )
		flac? ( media-libs/flac )
		dvd? ( media-libs/libdca media-libs/libdvdnav media-libs/libdvdread )
		cddb? ( media-libs/libcddb )
		cdda? ( media-libs/libcddb dev-libs/libcdio )
		pulseaudio? ( media-sound/pulseaudio )
		portaudio? ( media-libs/portaudio )
		avahi? ( net-dns/avahi )
		lirc? ( app-misc/lirc )
		upnp? ( net-libs/libupnp )
		v4l? ( media-libs/libv4l )
		samba? ( net-fs/samba )
		mtp? ( media-libs/libmtp )
		libproxy? ( net-libs/libproxy )
		speex? ( media-libs/speex )
		jack? ( media-sound/jack-audio-connection-kit )"
RDEPEND="${DEPEND}"
#ffmpeg[=aac]
#		media-libs/schroedinger
#		media-libs/libpng:1.2
#		ncurses? ( sys-libs/ncurses:5 )
#		aac? ( media-libs/faad2 )
RESTRICT="strip"

S="${WORKDIR}"

src_prepare(){
	for lang in ${LANGS};do
		for x in ${lang};do
			if ! use l10n_${x}; then
				rm -rf usr/share/locale/${x}
			fi
		done
	done
}
src_install(){
	cp -R usr "${D}"

	$(has_version ">=net-libs/gnutls-3.1.10") && dosym "libgnutls.so" "/usr/$(get_libdir)/libgnutls.so.26"
	dosym "liblua.so" "/usr/$(get_libdir)/liblua5.1.so.0"
	dosym "liba52.so" "/usr/$(get_libdir)/liba52-0.7.4.so"

	use pulseaudio || rm "${D}/usr/lib/acestreamplayer/plugins/audio_output/libpulse_plugin.so"
	use portaudio || rm "${D}/usr/lib/acestreamplayer/plugins/audio_output/libportaudio_plugin.so"
	use v4l || rm "${D}/usr/lib/acestreamplayer/plugins/access/libv4l2_plugin.so"
	use cdda || rm "${D}/usr/lib/acestreamplayer/plugins/access/libcdda_plugin.so"
	use modplug || rm "${D}/usr/lib/acestreamplayer/plugins/demux/libmod_plugin.so"
	use mpeg || rm "${D}/usr/lib/acestreamplayer/plugins/codec/liblibmpeg2_plugin.so"
	use speex || rm "${D}/usr/lib/acestreamplayer/plugins/codec/libspeex_plugin.so"
	use avahi || rm "${D}/usr/lib/acestreamplayer/plugins/services_discovery/libbonjour_plugin.so"
	#use aac || rm "${D}/usr/lib/acestreamplayer/plugins/codec/libfaad_plugin.so"
	use mad || rm "${D}/usr/lib/acestreamplayer/plugins/audio_filter/libmpgatofixed32_plugin.so"

	if use musepack;then
		dosym "libmpcdec.so" "/usr/$(get_libdir)/libmpcdec.so.6"
	else
		rm "${D}/usr/lib/acestreamplayer/plugins/demux/libmpc_plugin.so"
	fi

	if use matroska;then
		dosym "libmatroska.so" "/usr/$(get_libdir)/libmatroska.so.4"
	else
		rm "${D}/usr/lib/acestreamplayer/plugins/demux/libmkv_plugin.so"
	fi

	if ! use jack;then
		rm "${D}/usr/lib/acestreamplayer/plugins/audio_output/libjack_plugin.so"
		rm "${D}/usr/lib/acestreamplayer/plugins/access/libaccess_jack_plugin.so"
	fi

	if ! use dvd;then
		rm "${D}/usr/lib/acestreamplayer/plugins/access/libdvdread_plugin.so"
		rm "${D}/usr/lib/acestreamplayer/plugins/access/libdvdnav_plugin.so"
	fi

	if ! use flac;then
		rm "${D}/usr/lib/acestreamplayer/plugins/demux/libflacsys_plugin.so"
		rm "${D}/usr/lib/acestreamplayer/plugins/codec/libflac_plugin.so"
	fi

	if ! use vcdx;then
		rm "${D}/usr/lib/acestreamplayer/plugins/access/libvcd_plugin.so"
		rm "${D}/usr/lib/acestreamplayer/plugins/codec/libsvcdsub_plugin.so"
	fi
}
