# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools eutils fortran-2

DESCRIPTION="Suite of interactive programs for XAFS analysis"
HOMEPAGE="https://github.com/newville/ifeffit"
SRC_URI="http://archive.ubuntu.com/ubuntu/pool/multiverse/${P:0:1}/${PN}/${PN}_${PV}.orig.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"

RDEPEND="
	dev-perl/PGPLOT
"
#	sci-libs/pgplot[static-libs]
#pgplot still invisible for ifeffit. Probably, it is not a problem

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"

S="${WORKDIR}/${PN}-${PV}"
DESTDIR="${D}"

PATCHES=(
	"${FILESDIR}"/configuration_patches
	"${FILESDIR}"/documentation_patches
	"${FILESDIR}"/fortran_patches
	"${FILESDIR}"/readline_6.3_patch
	"${FILESDIR}"/unescaped-left-brace.patch
	"${FILESDIR}"/wrapper_patches
)
	#"${FILESDIR}"/ifeffit_pgplot.patch

src_configure() {
	default
}

src_compile() {
	make
}

pkg_install() {
	make install
}

pkg_postinst() {
	sed -i 's:/var/tmp/portage/sci-physics/ifeffit-9999/work/ifeffit-9999/src/pgstub/libnopgplot.a:/usr/lib64/libifeffit.a:' "${ROOT}"/usr/share/ifeffit/config/Config.mak || die "Sed failed!"
	sed -i 's:/var/tmp/portage/sci-physics/ifeffit-9999/work/ifeffit-9999/src/pgstub/libnopgplot.a:/usr/lib64/libifeffit.a:' "${ROOT}"/usr/share/ifeffit/config/TclSetup.in || die "Sed failed!"
	sed -i 's:/var/tmp/portage/sci-physics/ifeffit-9999/work/ifeffit-9999/src/pgstub/libnopgplot.a:/usr/lib64/libifeffit.a:' "${ROOT}"/usr/share/ifeffit/config/Makefile.PL || die "Sed failed!"
}
