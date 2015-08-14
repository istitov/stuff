# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2 flag-o-matic toolchain-funcs eutils

DESCRIPTION="Interact with the EFI Boot Manager"
HOMEPAGE="https://github.com/vathpela/efibootmgr"
EGIT_REPO_URI="https://github.com/vathpela/efibootmgr.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="sys-apps/pciutils
	sys-boot/efivar
	sys-libs/zlib"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_compile() {
	strip-flags
	tc-export CC
	emake EXTRA_CFLAGS="${CFLAGS}"
}

src_install() {
	# build system uses perl, so just do it ourselves
	dosbin src/efibootmgr/efibootmgr
	doman src/man/man8/efibootmgr.8
	dodoc AUTHORS README doc/ChangeLog doc/TODO
}
