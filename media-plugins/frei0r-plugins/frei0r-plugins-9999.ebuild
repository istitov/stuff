# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/frei0r-plugins/frei0r-plugins-1.4.ebuild,v 1.2 2013/08/27 20:38:19 aballier Exp $

EAPI=5
inherit cmake-utils multilib git-2

DESCRIPTION="A minimalistic plugin API for video effects"
HOMEPAGE="http://www.dyne.org/software/frei0r/"
EGIT_REPO_URI="https://github.com/ddennedy/frei0r.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ppc ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE="doc"

RDEPEND="x11-libs/cairo
	>=media-libs/opencv-2.3.0
	>=media-libs/gavl-1.2.0"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( app-doc/doxygen )"

DOCS=( AUTHORS ChangeLog README TODO )

src_prepare() {
	local f=CMakeLists.txt

	sed -i \
		-e '/set(CMAKE_C_FLAGS/d' \
		-e "/LIBDIR.*frei0r-1/s:lib:$(get_libdir):" \
		${f} || die

	# http://bugs.gentoo.org/418243
	sed -i \
		-e '/set.*CMAKE_C_FLAGS/s:"): ${CMAKE_C_FLAGS}&:' \
		src/filter/*/${f} || die
}

src_configure() {
	 local mycmakeargs=(
		-DWITHOUT_GAVL=OFF
		-DWITHOUT_OPENCV=ON
	 )
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	if use doc; then
		pushd doc
		doxygen || die
		popd
	fi
}

src_install() {
	cmake-utils_src_install

	use doc && dohtml -r doc/html
}
