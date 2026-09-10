# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 flag-o-matic

DESCRIPTION="Ogg Opus decoder plugin for DeaDBeeF audio player"
HOMEPAGE="https://bitbucket.org/Lithopsian/deadbeef-opus/overview"
EGIT_REPO_URI="https://bitbucket.org/Lithopsian/deadbeef-opus.git"

S="${WORKDIR}/${P}"
LICENSE="GPL-2"
SLOT="0"

# Default USE_OPUSURL gives direct dependencies on opus, OpenSSL, and opusurl.
# Declare the first two instead of relying on opusfile[http] transitively.
# verified 2026-07-27
DEPEND_COMMON="
	media-sound/deadbeef
	media-libs/opusfile[float,http]
	media-libs/libogg
	media-libs/opus
	dev-libs/openssl:="

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

PATCHES=( "${FILESDIR}/${PN}-gcc16.patch" )

src_prepare(){
	# Remove the forbidden /usr/local include path.
	sed -e 's|-I/usr/local/include/opus||' -i Makefile || die

	if use x86;then
		append-cflags -D_FILE_OFFSET_BITS=64
	fi
	default
}

src_install() {
	insinto /usr/$(get_libdir)/deadbeef
	doins opus.so
}
