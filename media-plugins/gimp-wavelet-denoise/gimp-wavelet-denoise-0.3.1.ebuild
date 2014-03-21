# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gimp-wavelet-denoise/gimp-wavelet-denoise-0.3.1.ebuild,v 0.1 2013/11/25 20:30:12 brothermechanic Exp $

EAPI="5"

inherit eutils

DESCRIPTION="Wavelet denoise plug-in for GIMP."
HOMEPAGE="http://registry.gimp.org/node/4235"
SRC_URI="http://registry.gimp.org/files/wavelet-denoise-0.3.1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="media-gfx/gimp"
RDEPEND=""

S="${WORKDIR}/wavelet-denoise-0.3.1/"

src_configure() {
	epatch "${FILESDIR}"/libm_and_po.patch
}

src_compile() {
	emake CFLAGS="${CFLAGS} -Wall $( gimptool-2.0 --cflags )"
}

src_install() {
	exeinto /usr/lib64/gimp/2.0/plug-ins/
	doexe src/wavelet-denoise
	for i in de ru it pl; do
		dodir "/usr/share/locale/${i}/LC_MESSAGES"
	done
	emake -C po install LOCALEDIR="${D}/usr/share/locale" || die "Install failed"

	exeinto "$( gimptool-2.0 --gimpplugindir )/plug-ins"
	doexe "src/${MY_PN}"

	dodoc AUTHORS ChangeLog INSTALL README THANKS TRANSLATIONS
}
