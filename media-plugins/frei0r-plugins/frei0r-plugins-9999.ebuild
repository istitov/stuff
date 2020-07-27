# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
inherit cmake multilib git-r3

DESCRIPTION="A minimalistic plugin API for video effects"
HOMEPAGE="http://www.dyne.org/software/frei0r/"
EGIT_REPO_URI="https://github.com/ddennedy/frei0r.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc"

RDEPEND="x11-libs/cairo
	>=media-libs/opencv-2.3.0
	>=media-libs/gavl-1.2.0"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( app-doc/doxygen )"

DOCS=( AUTHORS ChangeLog README.md TODO )

src_prepare() {
	default
	local f=CMakeLists.txt

	sed -i \
		-e '/set(CMAKE_C_FLAGS/d' \
		-e "/LIBDIR.*frei0r-1/s:lib:$(get_libdir):" \
		${f} || die

	# http://bugs.gentoo.org/418243
	sed -i \
		-e '/set.*CMAKE_C_FLAGS/s:"): ${CMAKE_C_FLAGS}&:' \
		src/filter/*/${f} || die
	cmake_src_prepare
}

src_configure() {
	 local mycmakeargs=(
		-DWITHOUT_GAVL=OFF
		-DWITHOUT_OPENCV=ON
	 )
	cmake_src_configure
}

src_compile() {
	cmake_src_compile

	if use doc; then
		pushd doc
		doxygen || die
		popd
	fi
}

src_install() {
	cmake_src_install

	use doc && dohtml -r doc/html
}
