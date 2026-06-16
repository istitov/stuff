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

# 4.3.x bundles its own XDR (mfhdf/libsrc/h4_xdr.c); libtirpc is no
# longer needed.
RDEPEND="virtual/zlib
	media-libs/libjpeg-turbo:=
	szip? ( virtual/szip )"
DEPEND="${RDEPEND}
	test? ( virtual/szip )"

src_prepare() {
	default

	# Upstream's configure.ac forces enable_shared=no when fortran is
	# requested, errors out if both are passed, and a later libtool
	# feature probe flips enable_shared back off post-hoc. Neutralize
	# the bodies so --enable-shared survives with --enable-fortran.
	# (Same intent as files/hdf-4.2.16-enable-fortran-shared.patch; sed
	# rather than a patch file because line numbers drift between
	# 4.2.x and 4.3.x.)
	sed -i \
		-e 's|^    enable_shared="no"$|    : # ours: honour --enable-shared|' \
		-e 's|AC_MSG_ERROR(\[Cannot build shared fortran libraries[^]]*\])|: # ours: allow shared fortran|' \
		-e '/^if (\.\/libtool --features | grep/,/^fi$/d' \
		configure.ac || die

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

	# 4.3.x dropped the autotools install rule for the example tree;
	# the sources are still shipped under HDF4Examples/. Copy them
	# verbatim so users still get them under USE=examples.
	if use examples; then
		docinto examples
		dodoc -r HDF4Examples/.
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
