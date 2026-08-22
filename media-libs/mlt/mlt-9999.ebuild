# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
inherit cmake flag-o-matic git-r3 python-single-r1

DESCRIPTION="Open source multimedia framework for television broadcasting"
HOMEPAGE="https://www.mltframework.org/"
EGIT_REPO_URI="https://github.com/mltframework/${PN}.git"

LICENSE="GPL-3"
SLOT="0/7"
IUSE="debug ffmpeg frei0r gtk jack libplacebo libsamplerate opencv opengl python qt6
	rnnoise rtaudio rubberband sdl sox test vdpau vidstab vorbis xine xml"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RESTRICT="!test? ( test )"

# rtaudio will use OSS on non linux OSes
# Qt already needs FFTW/PLUS so let's just always have it on to ensure
# MLT is useful: bug #603168.
RDEPEND="
	dev-libs/glib:2
	>=media-libs/libebur128-1.2.2:=
	sci-libs/fftw:3.0=
	ffmpeg? ( media-video/ffmpeg:0=[vdpau?] )
	frei0r? ( media-plugins/frei0r-plugins )
	gtk? (
		media-libs/fontconfig
		media-libs/libexif
		x11-libs/gdk-pixbuf:2
		x11-libs/pango
	)
	jack? (
		>=dev-libs/libxml2-2.5:=
		media-libs/ladspa-sdk
		virtual/jack
	)
	libplacebo? ( >=media-libs/libplacebo-5.229:= )
	libsamplerate? ( >=media-libs/libsamplerate-0.1.2 )
	opencv? (
		>=media-libs/opencv-4.5.1:=[contrib]
		|| (
			media-libs/opencv[ffmpeg]
			media-libs/opencv[gstreamer]
		)
	)
	opengl? (
		media-libs/libglvnd
		media-video/movit
	)
	python? ( ${PYTHON_DEPS} )
	qt6? (
		dev-qt/qtbase:6[gui,network,opengl,widgets,xml]
		dev-qt/qtsvg:6
		media-libs/libexif
		x11-libs/libX11
	)
	rtaudio? (
		>=media-libs/rtaudio-4.1.2:=
		kernel_linux? ( media-libs/alsa-lib )
	)
	rnnoise? ( media-libs/rnnoise:= )
	rubberband? ( media-libs/rubberband:= )
	sdl? (
		media-libs/libsdl2[X,opengl,video]
		media-libs/sdl2-image
	)
	sox? ( media-sound/sox:= )
	vidstab? ( media-libs/vidstab )
	vorbis? ( media-libs/libvorbis )
	xine? ( >=media-libs/xine-lib-1.1.2_pre20060328-r7 )
	xml? ( >=dev-libs/libxml2-2.5:= )
"
DEPEND="${RDEPEND}
	test? ( dev-qt/qtbase:6 )
"
BDEPEND="
	virtual/pkgconfig
	python? ( >=dev-lang/swig-2.0 )
"

DOCS=( AUTHORS NEWS README.md )

PATCHES=(
	"${FILESDIR}"/${PN}-6.10.0-swig-underlinking.patch
	"${FILESDIR}"/${PN}-6.22.1-no_lua_bdepend.patch
	"${FILESDIR}"/${PN}-7.0.1-cmake-symlink.patch
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_unpack() {
	# The sole submodule is only needed by the Qt 6 glaxnimate module.
	use qt6 || EGIT_SUBMODULES=()
	git-r3_src_unpack
}

src_prepare() {
	# Respect CFLAGS LDFLAGS when building shared libraries. Bug #308873
	if use python; then
		sed -i "/mlt.so/s/ -lmlt++ /& ${CFLAGS} ${LDFLAGS} /" src/swig/python/build || die
		python_fix_shebang src/swig/python
	fi

	# Kwalify is only used to validate YAML and is not needed to build MLT.
	sed -e '/find_package(Kwalify/ s/REQUIRED//' -i CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	# Workaround for bug #919981
	append-ldflags $(test-flags-CCLD -Wl,--undefined-version)

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON

		-DGPL=ON
		-DGPL3=ON
		-DBUILD_TESTING=$(usex test)
		-DCLANG_FORMAT=OFF
		-DBUILD_TESTS_WITH_QT6=ON

		-DMOD_AVFORMAT=$(usex ffmpeg)
		-DUSE_AVDEVICE=$(usex ffmpeg)
		-DMOD_FREI0R=$(usex frei0r)
		-DMOD_GDK=$(usex gtk)
		-DMOD_GLAXNIMATE_QT6=$(usex qt6)
		-DMOD_JACKRACK=$(usex jack)
		-DUSE_LV2=OFF
		-DUSE_VST2=OFF
		-DMOD_KDENLIVE=ON
		-DMOD_MOVIT=$(usex opengl)
		-DMOD_OPENCV=$(usex opencv)
		-DMOD_PLACEBO=$(usex libplacebo)
		-DMOD_PLUS=ON
		-DMOD_QT6=$(usex qt6)
		-DMOD_RESAMPLE=$(usex libsamplerate)
		-DMOD_RTAUDIO=$(usex rtaudio)
		-DMOD_RNNOISE=$(usex rnnoise)
		-DMOD_RUBBERBAND=$(usex rubberband)
		-DMOD_SDL1=OFF
		-DMOD_SDL2=$(usex sdl)
		-DMOD_SOX=$(usex sox)
		-DMOD_SPATIALAUDIO=OFF
		-DMOD_VIDSTAB=$(usex vidstab)
		-DMOD_VORBIS=$(usex vorbis)
		-DMOD_XINE=$(usex xine)
		-DMOD_XML=$(usex xml)
	)

	if use python; then
		mycmakeargs+=(
			-DSWIG_PYTHON=ON
			-DPython3_EXECUTABLE="${PYTHON}"
		)
	fi

	cmake_src_configure
}

src_test() {
	# See setenv in the upstream repository.
	local -x MLT_REPOSITORY="${BUILD_DIR}/out/lib/mlt"
	local -x MLT_DATA="${BUILD_DIR}/out/share/mlt"
	local -x MLT_PROFILES_PATH="${BUILD_DIR}/out/share/mlt/profiles"
	local -x MLT_PRESETS_PATH="${BUILD_DIR}/out/share/mlt/presets"
	local -x LD_LIBRARY_PATH="${BUILD_DIR}/out/lib:${LD_LIBRARY_PATH}"
	local -x PATH="${BUILD_DIR}/out/bin:${PATH}"

	local CMAKE_SKIP_TESTS=()
	use !xml && CMAKE_SKIP_TESTS+=( QtTest:xml )

	cmake_src_test
}

src_install() {
	cmake_src_install

	insinto /usr/share/${PN}
	doins -r demo

	# Install SWIG bindings
	docinto swig
	if use python; then
		dodoc "${S}"/src/swig/python/play.py
		python_optimize
	fi
}
