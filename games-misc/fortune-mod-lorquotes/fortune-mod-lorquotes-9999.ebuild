# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Best phrases of Linux.Org.Ru members, packaged for fortune"
HOMEPAGE="https://github.com/OlegKorchagin/lorquotes_archive"
SRC_URI="https://raw.githubusercontent.com/OlegKorchagin/lorquotes_archive/refs/heads/main/lor"
S="${WORKDIR}"

LICENSE="WTFPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="games-misc/fortune-mod"
BDEPEND="games-misc/fortune-mod"	# provides strfile

src_unpack() {
	# Upstream "archive" is the live \`lor\` text file on the main
	# branch of the GitHub repo. It has no extension, so portage
	# doesn't unpack - copy it into \${WORKDIR} under \${PN} instead.
	cp "${DISTDIR}/lor" "${S}/${PN}" || die
}

src_compile() {
	strfile "${PN}" || die
}

src_install() {
	insinto /usr/share/fortune
	doins "${PN}" "${PN}.dat"
}
