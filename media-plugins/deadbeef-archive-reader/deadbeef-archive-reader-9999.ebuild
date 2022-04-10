# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils subversion

DESCRIPTION="DeaDBeeF plugin for playing directly from RAR, 7z and Gzip archive files"
HOMEPAGE="http://subversion.assembla.com/svn/deadbeef_vfs_archive_reader/"
ESVN_REPO_URI="http://subversion.assembla.com/svn/deadbeef_vfs_archive_reader/trunk/src"

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
PATCHES=(
	"${FILESDIR}"/fix-blargg_ok-declaration.patch
)

src_install() {
	insinto /usr/$(get_libdir)/deadbeef
	doins ddb_archive_reader.so
}
#Not compiling
