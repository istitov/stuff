# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/ffmpeg/ffmpeg-0.10.7.ebuild,v 1.10 2013/04/13 07:42:54 ago Exp $

EAPI="4"

inherit eutils flag-o-matic multilib toolchain-funcs

DESCRIPTION="Old ffmpeg libs for use with AceStream, does not conflict with ffmpeg"
HOMEPAGE="http://ffmpeg.org/"
MY_PN="ffmpeg"
if [ "${PV%_p*}" != "${PV}" ] ; then # Snapshot
	SRC_URI="mirror://gentoo/${MY_PN}-${PV}.tar.bz2"
else # Release
	SRC_URI="http://ffmpeg.org/releases/${MY_PN}-${PV/_/-}.tar.bz2"
fi
FFMPEG_REVISION="${PV#*_p}"

LICENSE="GPL-2 amr? ( GPL-3 ) encode? ( aac? ( GPL-3 ) )"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="
	aac aacplus alsa amr bindist +bzip2 cdio celt cpudetection debug
	dirac doc +encode faac frei0r gnutls gsm +hardcoded-tables ieee1394 jack
	jpeg2k libass libv4l modplug mp3 network openal openssl oss pic pulseaudio
	rtmp schroedinger sdl speex static-libs test theora threads
	truetype v4l vaapi vdpau vorbis vpx X x264 xvid +zlib
	"

# String for CPU features in the useflag[:configure_option] form
# if :configure_option isn't set, it will use 'useflag' as configure option
CPU_FEATURES="3dnow:amd3dnow 3dnowext:amd3dnowext altivec avx mmx mmxext:mmx2 ssse3 vis neon"

for i in ${CPU_FEATURES}; do
	IUSE="${IUSE} ${i%:*}"
done

FFTOOLS="aviocat cws2fws ffeval graph2dot ismindex pktdumper qt-faststart trasher"

for i in ${FFTOOLS}; do
	IUSE="${IUSE} +fftools_$i"
done

RDEPEND="
	alsa? ( media-libs/alsa-lib )
	amr? ( media-libs/opencore-amr )
	bzip2? ( app-arch/bzip2 )
	cdio? ( || ( dev-libs/libcdio-paranoia <dev-libs/libcdio-0.90[-minimal] ) )
	celt? ( >=media-libs/celt-0.11.1 )
	dirac? ( media-video/dirac )
	encode? (
		aac? ( media-libs/vo-aacenc )
		aacplus? ( media-libs/libaacplus )
		amr? ( media-libs/vo-amrwbenc )
		faac? ( media-libs/faac )
		mp3? ( >=media-sound/lame-3.98.3 )
		theora? ( >=media-libs/libtheora-1.1.1[encode] media-libs/libogg )
		vorbis? ( media-libs/libvorbis media-libs/libogg )
		x264? ( >=media-libs/x264-0.0.20111017 )
		xvid? ( >=media-libs/xvid-1.1.0 )
	)
	frei0r? ( media-plugins/frei0r-plugins )
	gnutls? ( >=net-libs/gnutls-2.12.16 )
	gsm? ( >=media-sound/gsm-1.0.12-r1 )
	ieee1394? ( media-libs/libdc1394 sys-libs/libraw1394 )
	jack? ( media-sound/jack-audio-connection-kit )
	jpeg2k? ( >=media-libs/openjpeg-1.3-r2 )
	libass? ( media-libs/libass )
	libv4l? ( media-libs/libv4l )
	modplug? ( media-libs/libmodplug )
	openal? ( >=media-libs/openal-1.1 )
	pulseaudio? ( media-sound/pulseaudio )
	rtmp? ( >=media-video/rtmpdump-2.2f )
	sdl? ( >=media-libs/libsdl-1.2.13-r1[audio,video] )
	schroedinger? ( media-libs/schroedinger )
	speex? ( >=media-libs/speex-1.2_beta3 )
	truetype? ( media-libs/freetype:2 )
	vaapi? ( >=x11-libs/libva-0.32 )
	vdpau? ( x11-libs/libvdpau )
	vpx? ( >=media-libs/libvpx-0.9.6 )
	X? ( x11-libs/libX11 x11-libs/libXext x11-libs/libXfixes )
	zlib? ( sys-libs/zlib )
	!media-video/qt-faststart
	!media-libs/libpostproc
"

DEPEND="${RDEPEND}
	>=sys-devel/make-3.81
	dirac? ( virtual/pkgconfig )
	doc? ( app-text/texi2html )
	gnutls? ( virtual/pkgconfig )
	ieee1394? ( virtual/pkgconfig )
	libv4l? ( virtual/pkgconfig )
	mmx? ( dev-lang/yasm )
	rtmp? ( virtual/pkgconfig )
	schroedinger? ( virtual/pkgconfig )
	test? ( net-misc/wget )
	truetype? ( virtual/pkgconfig )
	v4l? ( sys-kernel/linux-headers )
"
# faac is license-incompatible with ffmpeg
REQUIRED_USE="bindist? ( encode? ( !faac !aacplus ) !openssl )
	libv4l? ( v4l )
	fftools_cws2fws? ( zlib )
	test? ( encode zlib )"

S=${WORKDIR}/${MY_PN}-${PV/_/-}

src_configure() {
	cd "${S}"
	./configure \
    --prefix=/usr \
    --enable-libmp3lame \
    --enable-libvorbis \
    --enable-libxvid \
    --enable-libx264 \
    --enable-libvpx \
    --enable-libtheora \
    --enable-libgsm \
    --enable-libspeex \
    --enable-postproc \
    --enable-shared \
    --enable-x11grab \
    --enable-libopencore_amrnb \
    --enable-libopencore_amrwb \
    --enable-libschroedinger \
    --enable-libopenjpeg \
    --enable-librtmp \
    --disable-libv4l2 \
    --enable-gpl \
    --enable-version3 \
    --enable-runtime-cpudetect \
    --disable-debug \
    --disable-static \
	$(use_enable pulseaudio libpulse) || die
}

src_install() {
	emake DESTDIR="${D}" install install-man
	rm -r "${D}"/usr/{bin,include,share}
	rm -r "${D}"/usr/lib/pkgconfig
	rm "${D}"/usr/lib/{libavcodec.so,libavformat.so,libavutil.so}
	rm "${D}"/usr/lib/{libavdevice.*,libavfilter.*,libpostproc.*,libswresample.*,libswscale.*,libavutil.so*}
}
