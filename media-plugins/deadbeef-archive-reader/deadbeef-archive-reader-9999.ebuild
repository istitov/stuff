# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="DeaDBeeF plugin for playing directly from RAR, 7z and Gzip archive files"
HOMEPAGE="https://github.com/carlosanunes/deadbeef_vfs_archive_reader"
EGIT_REPO_URI="https://github.com/carlosanunes/deadbeef_vfs_archive_reader"

S=${WORKDIR}/${P}/src
LICENSE="LGPL-2.1"
SLOT="0"

# The Makefile links -lz unconditionally; depend directly on virtual/zlib
# rather than relying on a transitive implementation.
# verified 2026-07-27
DEPEND_COMMON="
	media-sound/deadbeef
	virtual/zlib
"

RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"
src_prepare() {
	default
	sed -e 's/#define debug_printf 1 ? (void)0 : (void)/#define debug_printf(...) ((void)0)/' \
		-i fex/unrar/unrar.cpp || die
}

src_compile() {
	emake
}

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe ddb_archive_reader.so
}
