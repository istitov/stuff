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

# Upstream links -lopusfile -lopus -logg -lm, plus -lopusurl -lssl -lcrypto
# because USE_OPUSURL defaults to true and we do not override it, so opus.so
# has a direct DT_NEEDED on libopus and libssl/libcrypto. Both currently
# arrive through opusfile[http], which is not ours to depend on.
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

#QA_PRESTRIPPED="usr/$(get_libdir)/deadbeef/opus.so"

src_prepare(){
	# Upstream hardcodes an -I into /usr/local, which must not leak into a
	# sandboxed build.
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
