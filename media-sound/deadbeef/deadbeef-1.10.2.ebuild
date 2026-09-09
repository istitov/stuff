# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools xdg flag-o-matic toolchain-funcs plocale

DESCRIPTION="DeaDBeeF is a modular audio player similar to foobar2000"
HOMEPAGE="https://deadbeef.sourceforge.io/"
SRC_URI="https://sourceforge.net/projects/deadbeef/files/Builds/${PV}/linux/deadbeef-${PV}.tar.bz2/download
	-> ${P}.tar.bz2"

LICENSE="
	GPL-2
	LGPL-2.1
	MIT
	deadbeef_plugins_wavpack? ( BSD )
"
SLOT="0"
if [[ ${PV} != *beta* && ${PV} != *rc* ]]; then
	KEYWORDS="amd64 ~riscv x86"
fi
IUSE="
	deadbeef_plugins_aac deadbeef_plugins_adplug deadbeef_plugins_alac
	deadbeef_plugins_alsa deadbeef_plugins_ape +deadbeef_plugins_artwork
	deadbeef_plugins_cdda deadbeef_plugins_converter +deadbeef_plugins_curl
	deadbeef_plugins_dts deadbeef_plugins_dumb deadbeef_plugins_ffmpeg
	deadbeef_plugins_flac deadbeef_plugins_gme deadbeef_plugins_gtk2
	+deadbeef_plugins_gtk3 +deadbeef_plugins_hotkeys deadbeef_plugins_lastfm
	deadbeef_plugins_libretro deadbeef_plugins_libsamplerate
	+deadbeef_plugins_lyrics +deadbeef_plugins_m3u +deadbeef_plugins_medialib
	deadbeef_plugins_mms deadbeef_plugins_mono2stereo deadbeef_plugins_mp3
	+deadbeef_plugins_mpris deadbeef_plugins_musepack deadbeef_plugins_notify
	+deadbeef_plugins_nullout deadbeef_plugins_opus deadbeef_plugins_oss
	deadbeef_plugins_pipewire +deadbeef_plugins_playlist-browser
	deadbeef_plugins_psf deadbeef_plugins_pulseaudio
	+deadbeef_plugins_replaygain deadbeef_plugins_sc68 deadbeef_plugins_shellexec
	deadbeef_plugins_shorten deadbeef_plugins_sid deadbeef_plugins_sndfile
	deadbeef_plugins_soundtouch +deadbeef_plugins_supereq deadbeef_plugins_tta
	deadbeef_plugins_vorbis deadbeef_plugins_vtx deadbeef_plugins_wavpack
	deadbeef_plugins_wildmidi deadbeef_plugins_wma deadbeef_plugins_zip nls
"

REQUIRED_USE="
	|| ( deadbeef_plugins_alsa deadbeef_plugins_nullout deadbeef_plugins_oss
		deadbeef_plugins_pipewire deadbeef_plugins_pulseaudio )
	deadbeef_plugins_converter? (
		|| ( deadbeef_plugins_gtk2 deadbeef_plugins_gtk3 )
	)
	deadbeef_plugins_lastfm? ( deadbeef_plugins_curl )
	deadbeef_plugins_lyrics? (
		|| ( deadbeef_plugins_gtk2 deadbeef_plugins_gtk3 )
	)
	deadbeef_plugins_playlist-browser? (
		|| ( deadbeef_plugins_gtk2 deadbeef_plugins_gtk3 )
	)
"

DEPEND="
	dev-libs/glib:2
	dev-libs/jansson:=
	dev-libs/libdispatch
	virtual/zlib:=
	deadbeef_plugins_aac? ( media-libs/faad2 )
	deadbeef_plugins_alsa? ( media-libs/alsa-lib )
	deadbeef_plugins_cdda? (
		dev-libs/libcdio:=
		media-libs/libcddb
		media-sound/cdparanoia
	)
	deadbeef_plugins_dts? ( media-libs/libdca )
	deadbeef_plugins_ffmpeg? ( media-video/ffmpeg:= )
	deadbeef_plugins_flac? (
		media-libs/flac:=
		media-libs/libogg
	)
	deadbeef_plugins_curl? ( net-misc/curl )
	deadbeef_plugins_gtk2? ( x11-libs/gtk+:2 )
	deadbeef_plugins_gtk3? (
		>=app-accessibility/at-spi2-core-2.46.0
		media-libs/harfbuzz:=
		x11-libs/cairo
		x11-libs/gdk-pixbuf:2
		x11-libs/gtk+:3
		x11-libs/pango
	)
	deadbeef_plugins_hotkeys? ( x11-libs/libX11 )
	deadbeef_plugins_libsamplerate? ( media-libs/libsamplerate )
	deadbeef_plugins_mp3? ( media-sound/mpg123-base )
	deadbeef_plugins_musepack? ( media-sound/musepack-tools )
	nls? ( virtual/libintl )
	deadbeef_plugins_notify? ( sys-apps/dbus )
	deadbeef_plugins_opus? ( media-libs/opusfile )
	deadbeef_plugins_oss? ( virtual/os-headers )
	deadbeef_plugins_pipewire? ( media-video/pipewire:= )
	deadbeef_plugins_pulseaudio? ( media-libs/libpulse )
	deadbeef_plugins_sndfile? ( media-libs/libsndfile )
	deadbeef_plugins_vorbis? ( media-libs/libvorbis )
	deadbeef_plugins_wavpack? ( media-sound/wavpack )
	deadbeef_plugins_zip? ( dev-libs/libzip:= )
"

RDEPEND="
	${DEPEND}
	deadbeef_plugins_wildmidi? ( media-sound/timidity-freepats )
"

BDEPEND="
	dev-util/intltool
	llvm-core/clang
	>=sys-devel/gettext-0.21
	llvm-core/llvm
	deadbeef_plugins_ape? ( dev-lang/yasm )
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.10.1-drop-Werror.patch
	"${FILESDIR}"/${PN}-1.10.1-update-gettext.patch
	"${FILESDIR}"/${P}-mpris-toggle.patch
)

src_prepare() {
	default

	drop_from_linguas() {
		sed "/${1}/d" -i "${S}/po/LINGUAS" || die
	}

	drop_and_stub() {
		einfo drop_and_stub "${1}"
		rm -r "${1}" || die
		mkdir "${1}" || die
		cat > "${1}/Makefile.in" <<-EOF || die
			all: nothing
			install: nothing
			nothing:
		EOF
	}

	plocale_for_each_disabled_locale drop_from_linguas || die

	eautopoint --force
	eautoreconf

	# Get rid of bundled gettext. (Avoid build failures with musl)
	drop_and_stub "${S}/intl"

}

src_configure () {
	if ! tc-is-clang; then
		AR=llvm-ar
		CC=${CHOST}-clang
		CXX=${CHOST}-clang++
		NM=llvm-nm
		RANLIB=llvm-ranlib

		strip-unsupported-flags
	fi

	export HOST_CC="$(tc-getBUILD_CC)"
	export HOST_CXX="$(tc-getBUILD_CXX)"
	tc-export CC CXX LD AR NM OBJDUMP RANLIB PKG_CONFIG

	local artwork_network=no
	use deadbeef_plugins_artwork && use deadbeef_plugins_curl && artwork_network=yes

	local myconf=(
		"--disable-staticlink"
		"--disable-portable"
		"--disable-rpath"

		"--disable-coreaudio"
		"--disable-libmad"
		"$(use_enable deadbeef_plugins_aac aac)"
		"$(use_enable deadbeef_plugins_adplug adplug)"
		"$(use_enable deadbeef_plugins_alac alac)"
		"$(use_enable deadbeef_plugins_alsa alsa)"
		"$(use_enable deadbeef_plugins_ape ffap)"
		"$(use_enable deadbeef_plugins_artwork artwork)"
		"--enable-artwork-network=${artwork_network}"
		"$(use_enable deadbeef_plugins_cdda cdda)"
		"$(use_enable deadbeef_plugins_cdda cdda-paranoia)"
		"$(use_enable deadbeef_plugins_converter converter)"
		"$(use_enable deadbeef_plugins_curl vfs-curl)"
		"$(use_enable deadbeef_plugins_dts dca)"
		"$(use_enable deadbeef_plugins_dumb dumb)"
		"$(use_enable deadbeef_plugins_ffmpeg ffmpeg)"
		"$(use_enable deadbeef_plugins_flac flac)"
		"$(use_enable deadbeef_plugins_gme gme)"
		"$(use_enable deadbeef_plugins_gtk2 gtk2)"
		"$(use_enable deadbeef_plugins_gtk3 gtk3)"
		"$(use_enable deadbeef_plugins_hotkeys hotkeys)"
		"$(use_enable deadbeef_plugins_lastfm lfm)"
		"$(use_enable deadbeef_plugins_libretro libretro)"
		"$(use_enable deadbeef_plugins_libsamplerate src)"
		"$(use_enable deadbeef_plugins_lyrics lyrics)"
		"$(use_enable deadbeef_plugins_m3u m3u)"
		"$(use_enable deadbeef_plugins_medialib medialib)"
		"$(use_enable deadbeef_plugins_mms mms)"
		"$(use_enable deadbeef_plugins_mono2stereo mono2stereo)"
		"$(use_enable deadbeef_plugins_mp3 mp3)"
		"$(use_enable deadbeef_plugins_mp3 libmpg123)"
		"$(use_enable deadbeef_plugins_mpris mpris)"
		"$(use_enable deadbeef_plugins_musepack musepack)"
		"$(use_enable nls)"
		"$(use_enable deadbeef_plugins_notify notify)"
		"$(use_enable deadbeef_plugins_nullout nullout)"
		"$(use_enable deadbeef_plugins_opus opus)"
		"$(use_enable deadbeef_plugins_oss oss)"
		"$(use_enable deadbeef_plugins_pipewire pipewire)"
		"$(use_enable deadbeef_plugins_playlist-browser pltbrowser)"
		"$(use_enable deadbeef_plugins_psf psf)"
		"$(use_enable deadbeef_plugins_pulseaudio pulse)"
		"$(use_enable deadbeef_plugins_replaygain rgscanner)"
		"$(use_enable deadbeef_plugins_sc68 sc68)"
		"$(use_enable deadbeef_plugins_shellexec shellexec)"
		"$(use_enable deadbeef_plugins_shellexec shellexecui)"
		"$(use_enable deadbeef_plugins_shorten shn)"
		"$(use_enable deadbeef_plugins_sid sid)"
		"$(use_enable deadbeef_plugins_sndfile sndfile)"
		"$(use_enable deadbeef_plugins_soundtouch soundtouch)"
		"$(use_enable deadbeef_plugins_supereq supereq)"
		"$(use_enable deadbeef_plugins_tta tta)"
		"$(use_enable deadbeef_plugins_vorbis vorbis)"
		"$(use_enable deadbeef_plugins_vtx vtx)"
		"$(use_enable deadbeef_plugins_wavpack wavpack)"
		"$(use_enable deadbeef_plugins_wildmidi wildmidi)"
		"$(use_enable deadbeef_plugins_wma wma)"
		"$(use_enable deadbeef_plugins_zip vfs-zip)"

		"--enable-shared"
	)

	econf "${myconf[@]}"
}

src_install() {
	default

	find "${ED}" -name '*.la' -delete || die

	# if compressed, help doesn't work
	docompress -x /usr/share/doc/${PF}
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "DeaDBeeF plugins can be selected globally in make.conf, for example:"
	elog '  DEADBEEF_PLUGINS="alsa artwork curl gtk3 mpris nullout opus"'
	elog "Setting this variable replaces the default plugin selection."
	elog "For per-package selection, use deadbeef_plugins_* flags in package.use."
}
