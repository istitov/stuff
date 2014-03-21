# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

MY_PN="${PN/gimp-/}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Wavelet decompose plug-in for GIMP."
HOMEPAGE="http://registry.gimp.org/node/11742"
SRC_URI="http://registry.gimp.org/files/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="media-gfx/gimp"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

src_compile() {
	emake CFLAGS="${CFLAGS} -Wall $( gimptool-2.0 --cflags )"
}

src_install() {
	for i in de ru it pl; do
		dodir "/usr/share/locale/${i}/LC_MESSAGES"
	done
	emake -C po install LOCALEDIR="${D}/usr/share/locale" || die "Install failed"

	exeinto "$( gimptool-2.0 --gimpplugindir )/plug-ins"
	doexe "src/${MY_PN}"

	dodoc AUTHORS ChangeLog INSTALL README THANKS TRANSLATIONS
}
