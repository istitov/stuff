# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="QtAV"
inherit cmake qmake-utils git-r3

DESCRIPTION="Multimedia playback framework based on Qt + FFmpeg"
HOMEPAGE="https://www.qtav.org"
EGIT_REPO_URI="https://github.com/wang-bin/QtAV.git"
EGIT_BRANCH="master"
KEYWORDS=""

LICENSE="GPL-3+ LGPL-2.1+"
SLOT="0/1"
IUSE="gui opengl portaudio pulseaudio vaapi cuda"
#libav
REQUIRED_USE="gui? ( opengl )"

DEPEND="
	dev-qt/qtcore:5
	media-video/ffmpeg:=
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	media-video/ffmpeg:=
	gui? ( dev-qt/qtsql:5 )
	opengl? ( dev-qt/qtopengl:5 )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	cuda? ( dev-util/nvidia-cuda-toolkit )
"
#	libav? ( x11-libs/libX11
#		media-video/libav:= )
#	!libav? ( media-video/ffmpeg:= )

RDEPEND="${DEPEND}"

#S="${WORKDIR}/${MY_PN}-${PV}"

PATCHES=( "${FILESDIR}/${P}-multilib.patch" )
#do we need in the ffmpeg4-* patch here?

src_prepare() {
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTS=OFF
		-DBUILD_EXAMPLES=OFF
		-DBUILD_PLAYERS=$(usex gui)
		-DBUILD_QT5OPENGL=$(usex opengl)
		-DHAVE_PORTAUDIO=$(usex portaudio)
		-DHAVE_PULSE=$(usex pulseaudio)
		-DHAVE_VAAPI=$(usex vaapi)
	)

	cmake_src_configure
	pushd tools/install_sdk >/dev/null
	eqmake5
	popd >/dev/null
}

src_install() {
	cmake_src_install
	emake -C tools/install_sdk INSTALL_ROOT="${ED}" install
}
