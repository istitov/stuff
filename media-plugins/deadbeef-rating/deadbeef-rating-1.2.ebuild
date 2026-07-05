# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Track rating plugin for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/splushii/deadbeef-rating"
SRC_URI="https://github.com/splushii/deadbeef-rating/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/deadbeef-rating-${PV}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="media-sound/deadbeef"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/${P}-gcc16.patch" )

src_compile() {
	# rating.c does #include <deadbeef.h>, so point at the SDK headers.
	$(tc-getCC) ${CFLAGS} ${CPPFLAGS} -I"${ESYSROOT}/usr/include/deadbeef" \
		-Wall -fPIC -std=c99 -shared -o rating.so rating.c ${LDFLAGS} || die
}

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe rating.so
}
