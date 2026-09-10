# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FORTRAN_NEEDED=fortran

inherit fortran-2 toolchain-funcs autotools flag-o-matic

DESCRIPTION="General purpose library and format for storing scientific data"
HOMEPAGE="https://www.hdfgroup.org/solutions/hdf4/ https://github.com/HDFGroup/hdf4"
SRC_URI="https://github.com/HDFGroup/hdf4/archive/refs/tags/hdf${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/hdf4-hdf${PV}"

LICENSE="NCSA-HDF"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~riscv ~x86"
IUSE="examples fortran szip static-libs test"
RESTRICT="!test? ( test )"
REQUIRED_USE="test? ( szip )"

# 4.3 bundles XDR internally; libtirpc is unnecessary.
RDEPEND="virtual/zlib
	media-libs/libjpeg-turbo:=
	szip? ( virtual/szip )"
DEPEND="${RDEPEND}
	test? ( virtual/szip )"

src_prepare() {
	default

	# Upstream disables shared libraries when Fortran is enabled; neutralize
	# both checks so the configure flags can coexist.
	sed -i \
		-e 's|^    enable_shared="no"$|    : # ours: honour --enable-shared|' \
		-e 's|AC_MSG_ERROR(\[Cannot build shared fortran libraries[^]]*\])|: # ours: allow shared fortran|' \
		-e '/^if (\.\/libtool --features | grep/,/^fi$/d' \
		configure.ac || die

	sed -i -e 's/-R/-L/g' config/commence.am || die #rpath
	eautoreconf
}

src_configure() {
	# Avoid strict-aliasing and LTO type failures (Gentoo bug 862720).
	append-flags -fno-strict-aliasing
	filter-lto

	[[ $(tc-getFC) = *gfortran ]] && append-fflags -fno-range-check
	# Accept legacy Fortran argument mismatches (Gentoo bug 723014).
	append-fflags $(test-flags-FC -fallow-argument-mismatch)

	econf \
		--enable-shared \
		--enable-production=gentoo \
		--disable-netcdf \
		--disable-netcdf-tools \
		$(use_enable fortran) \
		$(use_enable static-libs static) \
		$(use_with szip szlib) \
		CC="$(tc-getCC)"
}

src_install() {
	default

	if ! use static-libs; then
		find "${ED}" -name '*.la' -delete || die
	fi

	dodoc release_notes/{RELEASE,HISTORY,bugs_fixed,misc_docs}.txt

	# 4.3 dropped the example install rule; install the shipped sources manually.
	if use examples; then
		docinto examples
		dodoc -r HDF4Examples/.
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
