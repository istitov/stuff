# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="Track rating plugin for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/splushii/deadbeef-rating"
EGIT_REPO_URI="https://github.com/splushii/deadbeef-rating.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""

DEPEND="media-sound/deadbeef"
RDEPEND="${DEPEND}"

src_compile() {
	# Upstream's \`build.sh\` insists on a --deadbeef-headers arg; do
	# the gcc call directly instead.
	$(tc-getCC) ${CFLAGS} ${CPPFLAGS} -Wall -fPIC -std=c99 -shared \
		-o rating.so rating.c ${LDFLAGS} || die
}

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe rating.so
}
