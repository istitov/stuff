# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools unpacker

DESCRIPTION="Suite of interactive programs for XAFS analysis"
HOMEPAGE="https://github.com/newville/ifeffit"

SRC_URI="http://mirrors.kernel.org/ubuntu/pool/multiverse/i/ifeffit/ifeffit_1.2.11d-10.2build2_amd64.deb"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE="doc"

RDEPEND="
	sci-libs/pgplot
	dev-perl/PGPLOT
"
#pgplot still invisible for ifeffit. Probably, it is not a problem

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"


S="${WORKDIR}"
DESTDIR="${D}"

src_unpack(){
        unpack_deb ${A}
}

src_install(){
        cp -R "${WORKDIR}/usr" "${D}" || die "install failed!"
}
