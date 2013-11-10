# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-dicts/aspell-ky/aspell-ky-0.1.0.ebuild,v 0.1 2013/11/10 14:37:41 brothermechanic Exp $

ASPELL_LANG="Kirghiz"
ASPOSTFIX="6"

inherit aspell-dict

LICENSE="GPL-2"

KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
IUSE=""

# very strange filename not supported by the gentoo naming scheme
FILENAME=aspell6-ky-0.01-0

SRC_URI="mirror://gnu/aspell/dict/ky/${FILENAME}.tar.bz2"
S=${WORKDIR}/${FILENAME}

src_unpack() {
	unpack ${A}
	cd "${S}"
}

