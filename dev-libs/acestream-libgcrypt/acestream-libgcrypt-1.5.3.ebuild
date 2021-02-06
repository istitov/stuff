# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
AUTOTOOLS_AUTORECONF=1

inherit autotools-utils

MY_PN="${PN#acestream-}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="General purpose crypto library based on the code used in GnuPG"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/libgcrypt/${MY_P}.tar.bz2 -> ${MY_P}.tar.bz2
	mirror://ftp.gnupg.org/gcrypt/${MY_PN}/${MY_P}.tar.bz2 -> ${MY_P}.tar.bz2"

LICENSE="LGPL-2.1 MIT"
SLOT="0/11" # subslot = soname major version
KEYWORDS="amd64 arm arm64 hppa ~m68k ~mips ppc ppc64 s390 sparc x86 ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris" #alpha, ia64 were removed due to '>=dev-libs/libgpg-error-1.8', '>=app-portage/elt-patches-20170815', '>=sys-devel/automake-1.16.1:1.16', '>=sys-devel/autoconf-2.69', '>=sys-devel/libtool-2.4'
IUSE="static-libs"

RDEPEND=">=dev-libs/libgpg-error-1.8"
DEPEND="${RDEPEND}"

DOCS=( AUTHORS ChangeLog NEWS README THANKS TODO )

PATCHES=(
	"${FILESDIR}"/${MY_PN}-1.5.0-uscore.patch
	"${FILESDIR}"/${MY_PN}-multilib-syspath.patch
)

S="${WORKDIR}/${MY_P}"

src_configure() {
	local myeconfargs=(
		--disable-padlock-support # bug 201917
		--disable-dependency-tracking
		--enable-noexecstack
		--disable-O-flag-munging
		$(use_enable static-libs static)

		# disabled due to various applications requiring privileges
		# after libgcrypt drops them (bug #468616)
		--without-capabilities

		# http://trac.videolan.org/vlc/ticket/620
		# causes bus-errors on sparc64-solaris
		$([[ ${CHOST} == *86*-darwin* ]] && echo "--disable-asm")
		$([[ ${CHOST} == sparcv9-*-solaris* ]] && echo "--disable-asm")
	)
	autotools-utils_src_configure
}

src_install(){
	dolib "${BUILD_DIR}"/src/.libs/libgcrypt.so.*
}
