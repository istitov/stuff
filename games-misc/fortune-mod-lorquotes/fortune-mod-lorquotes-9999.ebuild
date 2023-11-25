# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=2
MY_PN=${PN/mod-/}
DESCRIPTION="The best phrases of Linux.Org.Ru members"
HOMEPAGE="http://lorquotes.ru/,"
#SRC_URI="http://lorquotes.ru/fortraw.php"

LICENSE="WTFPL-2"
SLOT="0"
KEYWORDS="amd64 arm ~amd64-linux ~x86-linux"

RDEPEND="games-misc/fortune-mod"

S=${WORKDIR}/${MY_PN}

src_prepare(){
	wget -c http://lorquotes.ru/fortraw.php
	iconv -f koi8r -t utf8 "${WORKDIR}/fortraw.php" > "${WORKDIR}/${PN}"
	strfile "${WORKDIR}/${PN}"
}
src_install() {
	insinto /usr/share/fortune
	doins ${PN} ${PN}.dat || die
}
