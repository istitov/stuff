# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic

DESCRIPTION="Ogg Opus decoder plugin for DeaDBeeF audio player"
HOMEPAGE="https://bitbucket.org/Lithopsian/deadbeef-opus/overview"
# Upstream stopped uploading release tarballs to bitbucket downloads/
# at 0.6; switch to the per-tag git archive instead. The archive's top
# directory is named Lithopsian-deadbeef-opus-<sha12>/, which we rename
# to ${P} in src_unpack so the rest of the ebuild keeps using S=${P}.
SRC_URI="https://bitbucket.org/Lithopsian/deadbeef-opus/get/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${P}"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND_COMMON="
	media-sound/deadbeef
	media-libs/opusfile[float,http]
	media-libs/libogg"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

PATCHES=( "${FILESDIR}/${PN}-gcc16.patch" )

#QA_PRESTRIPPED="usr/$(get_libdir)/deadbeef/opus.so"

src_unpack() {
	default
	mv "${WORKDIR}"/Lithopsian-deadbeef-opus-* "${S}" || die
}

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
