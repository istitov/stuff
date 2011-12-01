# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
EAPI=2
MY_PN=${PN/mod-/}
DESCRIPTION="The best phrases of Linux.Org.Ru members"
HOMEPAGE="http://lorquotes.ru/,"
SRC_URI="http://lorquotes.ru/fortraw.php"

LICENSE="WTFPL" 
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND="games-misc/fortune-mod"

S=${WORKDIR}/${MY_PN}

src_prepare(){
iconv -f koi8r -t utf8 "${DISTDIR}/fortraw.php" > "${WORKDIR}/${PN}"
strfile "${WORKDIR}/${PN}"
}
src_install() {
	insinto /usr/share/fortune
	doins  ${PN}  ${PN}.dat || die
}
