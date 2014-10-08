# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
DESCRIPTION="JJFFE is set of recompiled replacement executables for the game Frontier: First Encounters."
HOMEPAGE="http://jaj22.org.uk/jjffe/"
SRC_URI="
http://web.archive.org/web/20090720024914/http://jaj22.org.uk/jjffe/jjffe28a7s.zip
http://jaj22.org.uk/jjffe/jjffe28a7s.zip
http://ffeartpage.com/b2/firstenc.zip
"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RESTRICT="strip mirror"
RDEPEND="
media-libs/libsdl
app-arch/unzip
"
inherit eutils
DEPEND="
>=dev-lang/nasm-2.09.10
${RDEPEND}
"

src_unpack() {
	mkdir -p "${S}"
	cd "${S}"
	for f in ${A}; do
		echo ${f}
		unzip -qqL "${PORTAGE_TMPDIR}/portage/${CATEGORY}/${PF}/distdir/${f}"
	done
	epatch "${FILESDIR}"/gcc32.patch
	epatch "${FILESDIR}"/gentoopath.patch
}

src_compile() {
	replace-cpu-flags athlon64 i386
	emake -f ffelnxsdl.mak || die "emake failed"
}

src_install() {
	into /usr/games
	dobin ffelnxsdl
	insinto /usr/games/lib/jjffe
	cp -dpR "${WORKDIR}"/firstenc "${D}"/usr/games/lib/jjffe
}
