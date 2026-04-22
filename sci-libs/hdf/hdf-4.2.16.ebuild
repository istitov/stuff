# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FORTRAN_NEEDED=fortran

inherit fortran-2 toolchain-funcs autotools flag-o-matic

DESCRIPTION="General purpose library and format for storing scientific data"
HOMEPAGE="https://www.hdfgroup.org/hdf4.html"
SRC_URI="https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF4/HDF${PV}-2/src/${P}-2.tar.bz2"
S="${WORKDIR}/${P}-2"

LICENSE="NCSA-HDF"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~riscv ~x86"
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

	sed -i -e 's/-R/-L/g' config/commence.am || die #rpath
	eautoreconf
}

src_configure() {
	# -Werror=strict-aliasing, -Werror=lto-type-mismatch
	# https://bugs.gentoo.org/862720
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
