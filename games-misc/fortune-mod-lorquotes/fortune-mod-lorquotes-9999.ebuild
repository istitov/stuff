# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=2
MY_PN=${PN/mod-/}
DESCRIPTION="The best phrases of Linux.Org.Ru members"
HOMEPAGE="https://github.com/OlegKorchagin/lorquotes_archive"
SRC_URI="https://raw.githubusercontent.com/OlegKorchagin/lorquotes_archive/refs/heads/main/lor"
S=${WORKDIR}/${MY_PN}

LICENSE="WTFPL-2"
SLOT="0"
KEYWORDS="amd64 arm ~amd64-linux ~x86-linux"

RDEPEND="games-misc/fortune-mod"

src_prepare(){

#	wget -c $SRC_URI > "${WORKDIR}/${PN}"
	strfile "${WORKDIR}/${PN}"
}
src_install() {
	insinto /usr/share/fortune
	doins ${PN} ${PN}.dat || die
}
