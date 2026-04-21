# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="VFS plugin for DeaDBeeF: play audio from RAR archives"
HOMEPAGE="https://github.com/DeaDBeeF-Player/vfs_rar"
EGIT_REPO_URI="https://github.com/DeaDBeeF-Player/vfs_rar.git"
EGIT_SUBMODULES=( '*' )

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""

DEPEND="media-sound/deadbeef"
RDEPEND="${DEPEND}"

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe vfs_rar.so
}
