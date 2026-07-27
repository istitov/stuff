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

# src/Makefile defaults ZLIB_LIBS to -lz and folds it into LDFLAGS
# unconditionally, so ddb_archive_reader.so carries a direct DT_NEEDED on
# libz. zlib is not in @system, it just happens to be installed everywhere
# as a transitive dependency. The virtual rather than sys-libs/zlib because
# nothing here needs the reference implementation over zlib-ng[compat].
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
#PATCHES=(
#	"${FILESDIR}"/fix-blargg_ok-declaration.patch
#)

src_prepare() {
	default
}

src_compile() {
	emake
}

src_install() {
	insinto /usr/$(get_libdir)/deadbeef
	doins ddb_archive_reader.so
}
