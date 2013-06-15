# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/djv/djv-0.9.0.ebuild,v 1.2 2013/03/15 05:50:23 perestoronin Exp $

EAPI="5"

inherit cmake-utils eutils

MY_P=${PN}-${PV}

DESCRIPTION="Professional movie playback and image processing software for the film and computer animation industries."
HOMEPAGE="http://djv.sf.net"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}_src.tar.gz"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="ffmpeg jpeg png quicktime tiff"

RDEPEND=">=x11-libs/fltk-1.1
		>=media-libs/openexr-1.6.1
		>=media-libs/glew-1.4
		ffmpeg? ( >=media-video/ffmpeg-0.4.9 )
		jpeg? ( >=media-libs/jpeg-6b )
		png? ( >=media-libs/libpng-1.2 )
		quicktime? ( >=media-libs/libquicktime-1.0 )
		tiff? ( >=media-libs/tiff-3.8.2 )"

DEPEND="${RDEPEND}
	>=dev-util/cmake-2.4.4"

S=${WORKDIR}/${MY_P}

files_fix="djv_file.h djv_file.cpp djv_file_inline.h djv_user.h djv_user.cpp"

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_compile() {
	# Commented out options cause compilation errors, some
	# might need -Wl,--as-needed in LDFLAGS and all USE
	# flags disabled for reproducing. -drac
	# TODO. Needs to be fixed, or reported upstream.

	local mycmakeargs

	# CMakeLists.txt
	#use qt4 || mycmakeargs="${mycmakeargs} -DNO_QT4=1"

	# uid_t and gid_t is not #defined, fix
	for file_fix in ${files_fix}; do
	mv lib/djv_core/${file_fix} \
		lib/djv_core/${file_fix}.orig
	sed -e 's/uid_t /__uid_t /' \
		-e 's/uid_t)/__uid_t)/' \
	lib/djv_core/${file_fix}.orig \
		> lib/djv_core/${file_fix}
	done

	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
	newicon etc/X11/projector32x32.png "${PN}".png
	make_desktop_entry djv_view "DJV View" djv AudioVideo "MimeType=image/exr;image/openexr;image/x-exr;"
}
