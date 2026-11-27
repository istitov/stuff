# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit fortran-2 meson

DESCRIPTION="Weighted orthogonal distance regression (ODR) library in modern Fortran"
HOMEPAGE="https://github.com/HugoMVale/odrpack95"
SRC_URI="
	https://github.com/HugoMVale/odrpack95/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
# The shared library carries no versioned SONAME, so key the subslot to
# the release.
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="virtual/blas"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	# Upstream installs only the library; add the C header and a
	# pkg-config file for consumers such as dev-python/odrpack.
	"${FILESDIR}"/${P}-install-header-pc.patch
)

src_configure() {
	# auto picks the system BLAS through pkg-config; it only falls back to
	# the bundled reference BLAS when none is found.
	local emesonargs=(
		-Dblas_option=auto
		-Dbuild_shared=true
		$(meson_use test build_tests)
	)
	meson_src_configure
}
