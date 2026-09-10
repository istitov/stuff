# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic

DESCRIPTION="Ogg Opus decoder plugin for DeaDBeeF audio player"
HOMEPAGE="https://bitbucket.org/Lithopsian/deadbeef-opus/overview"
# Releases after 0.6 use tag archives with hash-suffixed roots, renamed below.
SRC_URI="https://bitbucket.org/Lithopsian/deadbeef-opus/get/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${P}"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

# USE_OPUSURL is enabled and creates direct Opus/OpenSSL link dependencies;
# declare them rather than relying on opusfile[http].
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

src_unpack() {
	default
	mv "${WORKDIR}"/Lithopsian-deadbeef-opus-* "${S}" || die
}

src_prepare(){
	# Remove the hardcoded /usr/local include path.
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
