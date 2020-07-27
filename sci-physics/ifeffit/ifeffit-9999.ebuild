# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools eutils fortran-2 git-r3

DESCRIPTION="Suite of interactive programs for XAFS analysis"
HOMEPAGE="https://github.com/newville/ifeffit"
EGIT_REPO_URI="git://github.com/newville/ifeffit.git"

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


S="${WORKDIR}/${PN}-${PV}"
DESTDIR="${D}"

PATCHES=(
	"${FILESDIR}"/configuration_patches
)

pkg_configure() {
	default
}

pkg_compile() {
	make -k
}

pkg_install() {
	make -k install
}
