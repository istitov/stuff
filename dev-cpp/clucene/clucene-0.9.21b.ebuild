# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

MY_P=${PN}-core-${PV}
inherit autotools

DESCRIPTION="High-performance, full-featured text search engine based off of lucene in C++"
HOMEPAGE="http://clucene.sourceforge.net/"
SRC_URI="mirror://sourceforge/clucene/${MY_P}.tar.bz2"

LICENSE="|| ( Apache-2.0 LGPL-2.1 )"
SLOT="1"
KEYWORDS="alpha amd64 ~arm hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="debug doc static-libs threads"

DEPEND="doc? ( >=app-doc/doxygen-1.4.2 )"
RDEPEND=""

PATCHES=(
	"${FILESDIR}/${P}-gcc44.patch"
	"${FILESDIR}/${P}-doxygen.patch"
)

S="${WORKDIR}/${MY_P}"

src_prepare() {
	base_src_prepare

	# fix wrong aclocal_amflags
	sed -i \
		-e '/ACLOCAL_AMFLAGS/d' \
		Makefile.am || die

	AT_M4DIR='-I m4' eautoreconf
}

src_configure() {
	econf \
		$(use_enable debug) \
		$(use_enable debug cnddebug) \
		$(use_enable static-libs static) \
		$(use_enable threads multithreading)
}

src_compile() {
	base_src_compile
	if use doc ; then
		emake doxygen || die "making docs failed"
	fi
}

src_install() {
	base_src_install
	use doc && { dohtml "${S}"/doc/html/* ; }

	find "${D}" -type f -name '*.la' -exec rm -f {} + \
		|| die "la removal failed"
}
