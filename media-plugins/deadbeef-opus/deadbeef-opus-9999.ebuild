# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 flag-o-matic

DESCRIPTION="Ogg Opus decoder plugin for DeaDBeeF audio player."
HOMEPAGE="https://bitbucket.org/Lithopsian/deadbeef-opus/overview"
EGIT_REPO_URI="https://bitbucket.org/Lithopsian/deadbeef-opus.git"

LICENSE="GPL-2"
SLOT="0"

DEPEND_COMMON="
	media-sound/deadbeef
	media-libs/opusfile[float,http]
	media-libs/libogg"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

S="${WORKDIR}/${P}"

#QA_PRESTRIPPED="usr/$(get_libdir)/deadbeef/opus.so"

src_prepare(){
	sed \
		-e 's|-I/usr/local/include/opus||'\
		-e 's|$(CC) $(LDFLAGS) $(OBJECTS) -o $@|$(CC) $(OBJECTS) $(LDFLAGS) -o $@|'\
		-i Makefile

	if use x86;then
		append-cflags -D_FILE_OFFSET_BITS=64
	fi
	default
}

src_install() {
	insinto /usr/$(get_libdir)/deadbeef
	doins opus.so
}
