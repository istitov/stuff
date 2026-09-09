# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT="7705adf7470e344f38ea6d020313630fa568a001"
UNRAR_PV="7.2.6"

DESCRIPTION="VFS plugin for DeaDBeeF: play audio from RAR archives"
HOMEPAGE="https://github.com/DeaDBeeF-Player/vfs_rar"
SRC_URI="
	https://github.com/DeaDBeeF-Player/vfs_rar/archive/${COMMIT}.tar.gz -> ${P}.tar.gz
	https://www.rarlab.com/rar/unrarsrc-${UNRAR_PV}.tar.gz -> unrar-${UNRAR_PV}.tar.gz
"
S="${WORKDIR}/vfs_rar-${COMMIT}"

LICENSE="GPL-2+ unRAR"
SLOT="0"
KEYWORDS=""

DEPEND="media-sound/deadbeef"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-unrar-no-isnt.patch"
	"${FILESDIR}/${PN}-unrar7-port.patch"
)

src_unpack() {
	default
	rm -rf "${S}/unrar" || die
	mv "${WORKDIR}/unrar" "${S}/unrar" || die
}

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe vfs_rar.so
}
