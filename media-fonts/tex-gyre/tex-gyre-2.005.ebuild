# Copyright 2008-2011 Funtoo Technologies
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils font latex-package
DESCRIPTION="The TeX Gyre (TG) Collection of Fonts"
HOMEPAGE="http://www.gust.org.pl/projects/e-foundry/tex-gyre"

LICENSE="GUST LPPL-1.3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="latex"

#if use latex;then
SRC_URI="http://www.gust.org.pl/projects/e-foundry/tex-gyre/whole/tg-2.005bas.zip"
#else
#SRC_URI="http://www.gust.org.pl/projects/e-foundry/tex-gyre/whole/tg-2.005otf.zip"
#fi

DEPEND=""
RDEPEND="${DEPEND}"

SUPPLIER="tex-gyre"

S=${WORKDIR}
FONT_S="${S}/fonts/opentype/public/${PN}/"
FONT_SUFFIX="otf"
DOCS="${S}/doc/fonts/${PN}/*"
#FONT_PN = "tex-gyre"

#pkg_postinst() {
#	font_pkg_postinst
#}
src_install() {
cd "${S}/tex/latex/${PN}"
latex-package_src_install
cd "${S}/fonts/afm/public/${PN}"
latex-package_src_install
cd "${S}/fonts/enc/dvips/${PN}"
latex-package_src_install
cd "${S}/fonts/map/dvips/${PN}"
latex-package_src_install
cd "${S}/fonts/opentype/public/${PN}"
latex-package_src_install
cd "${S}/fonts/tfm/public/${PN}"
latex-package_src_install
cd "${S}/fonts/type1/public/${PN}"
latex-package_src_install
cd "${S}/doc/fonts/${PN}"
latex-package_src_install
#Let's install opentype fonts now
font_src_install
}
