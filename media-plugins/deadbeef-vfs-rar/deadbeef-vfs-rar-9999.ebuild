# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="VFS plugin for DeaDBeeF: play audio from RAR archives"
HOMEPAGE="https://github.com/DeaDBeeF-Player/vfs_rar"
EGIT_REPO_URI="https://github.com/DeaDBeeF-Player/vfs_rar.git"
# The Makefile expects unbundled RARLAB sources in unrar/. Match app-arch/unrar's
# distfile name to retain Gentoo mirror fallback.
UNRAR_PV="7.2.6"
SRC_URI="https://www.rarlab.com/rar/unrarsrc-${UNRAR_PV}.tar.gz -> unrar-${UNRAR_PV}.tar.gz"

LICENSE="GPL-2+ unRAR"
SLOT="0"
KEYWORDS=""

DEPEND="media-sound/deadbeef"
RDEPEND="${DEPEND}"

# unrar-no-isnt drops Windows-only isnt.o. unrar7-port adapts the inactive
# plugin from UnRAR 6 APIs to 7.x.
PATCHES=(
	"${FILESDIR}/${PN}-unrar-no-isnt.patch"
	"${FILESDIR}/${PN}-unrar7-port.patch"
)

src_unpack() {
	git-r3_src_unpack
	# Move unpacked UnRAR sources to the Makefile's expected path.
	unpack "unrar-${UNRAR_PV}.tar.gz"
	rm -rf "${S}/unrar"
	mv "${WORKDIR}/unrar" "${S}/unrar" || die
}

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe vfs_rar.so
}
