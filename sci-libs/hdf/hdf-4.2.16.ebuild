# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FORTRAN_NEEDED=fortran

inherit fortran-2 toolchain-funcs autotools flag-o-matic

DESCRIPTION="General purpose library and format for storing scientific data"
HOMEPAGE="https://www.hdfgroup.org/solutions/hdf4/ https://github.com/HDFGroup/hdf4"
# Tags use hdf-X_Y_Z-2; the suffix is the patch level.
SRC_URI="https://github.com/HDFGroup/hdf4/archive/refs/tags/hdf-$(ver_rs 1- _)-2.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/hdf4-hdf-$(ver_rs 1- _)-2"

LICENSE="NCSA-HDF"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~riscv ~x86"
IUSE="examples fortran szip static-libs test"
RESTRICT="!test? ( test )"
REQUIRED_USE="test? ( szip )"

RDEPEND="net-libs/libtirpc:=
	virtual/zlib
	media-libs/libjpeg-turbo:=
	szip? ( virtual/szip )"
DEPEND="${RDEPEND}
	test? ( virtual/szip )"

PATCHES=(
	"${FILESDIR}"/${PN}-4.2.16-enable-fortran-shared.patch
)

src_prepare() {
	default

	# Do not encode library search paths as RPATHs.
	sed -i -e 's/-R/-L/g' config/commence.am || die
	eautoreconf
}

src_configure() {
	# Avoid strict-aliasing and LTO type errors (bug 862720).
	append-flags -fno-strict-aliasing
	filter-lto

	[[ $(tc-getFC) = *gfortran ]] && append-fflags -fno-range-check
	# GCC 10 workaround, bug #723014
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

	cd "${ED}/usr" || die
	if use examples; then
		mv  share/hdf4_examples share/doc/${PF}/examples || die
		docompress -x /usr/share/doc/${PF}/examples
	else
		rm -r share/hdf4_examples || die
	fi
}
