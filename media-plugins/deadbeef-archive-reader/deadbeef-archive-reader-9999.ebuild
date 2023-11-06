# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils git-r3

DESCRIPTION="DeaDBeeF plugin for playing directly from RAR, 7z and Gzip archive files"
HOMEPAGE="https://github.com/carlosanunes/deadbeef_vfs_archive_reader"
EGIT_REPO_URI="https://github.com/carlosanunes/deadbeef_vfs_archive_reader"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="media-sound/deadbeef"

RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"
S=${WORKDIR}/${P}/src
#PATCHES=(
#	"${FILESDIR}"/fix-blargg_ok-declaration.patch
#)

src_prepare() {
	./configure
	default
}

src_compile() {
	emake
}

src_install() {
	insinto /usr/$(get_libdir)/deadbeef
	doins ddb_archive_reader.so
}
