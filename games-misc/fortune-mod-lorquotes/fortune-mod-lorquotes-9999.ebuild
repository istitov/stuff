# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Best phrases of Linux.Org.Ru members, packaged for fortune"
HOMEPAGE="https://github.com/OlegKorchagin/lorquotes_archive"
EGIT_REPO_URI="https://github.com/OlegKorchagin/lorquotes_archive.git"

inherit git-r3

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS=""

RDEPEND="games-misc/fortune-mod"
BDEPEND="games-misc/fortune-mod"	# provides strfile

src_compile() {
	strfile lor || die
}

src_install() {
	insinto /usr/share/fortune
	newins lor "${PN}"
	newins lor.dat "${PN}.dat"
}
