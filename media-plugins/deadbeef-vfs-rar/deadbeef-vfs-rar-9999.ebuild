# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="VFS plugin for DeaDBeeF: play audio from RAR archives"
HOMEPAGE="https://github.com/DeaDBeeF-Player/vfs_rar"
EGIT_REPO_URI="https://github.com/DeaDBeeF-Player/vfs_rar.git"
# vfs_rar has no submodule; its Makefile expects the RARLAB UnRAR library
# source unpacked into unrar/ (see upstream README). Provide it here. The
# distfile name matches app-arch/unrar so the gentoo mirror is a fallback.
UNRAR_PV="7.2.6"
SRC_URI="https://www.rarlab.com/rar/unrarsrc-${UNRAR_PV}.tar.gz -> unrar-${UNRAR_PV}.tar.gz"

LICENSE="GPL-2+ unRAR"
SLOT="0"
KEYWORDS=""

DEPEND="media-sound/deadbeef"
RDEPEND="${DEPEND}"

# unrar-no-isnt: drop the Windows-only isnt.o from the plugin's UNRAR_OBJS.
# unrar7-port: vfs_rar.cpp uses UnRAR 6.x-era APIs (NM macro, wchar FileName,
# ConvertPath buffer form) that 7.x changed; upstream is inactive and no fork
# has ported it, so carry the port locally.
PATCHES=(
	"${FILESDIR}/${PN}-unrar-no-isnt.patch"
	"${FILESDIR}/${PN}-unrar7-port.patch"
)

src_unpack() {
	git-r3_src_unpack
	# unrarsrc unpacks to unrar/ in WORKDIR; drop it into the plugin's
	# expected path (its Makefile compiles unrar/*.cpp).
	unpack "unrar-${UNRAR_PV}.tar.gz"
	rm -rf "${S}/unrar"
	mv "${WORKDIR}/unrar" "${S}/unrar" || die
}

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe vfs_rar.so
}
