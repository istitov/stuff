# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FORTRAN_NEEDED=fortran

inherit cmake flag-o-matic fortran-2 toolchain-funcs

DESCRIPTION="General purpose library and format for storing scientific data"
HOMEPAGE="https://www.hdfgroup.org/solutions/hdf4/ https://github.com/HDFGroup/hdf4"
SRC_URI="https://github.com/HDFGroup/hdf4/archive/refs/tags/hdf${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/hdf4-hdf${PV}"

LICENSE="NCSA-HDF"
# The CMake port replaces libdf.so.0/libmfhdf.so.0 with libhdf.so.11 and
# libmfhdf.so.11. Its intended libdf compatibility symlink fails silently.
SLOT="0/11"
KEYWORDS="~amd64 ~arm64"
IUSE="examples fortran szip static-libs test"
RESTRICT="!test? ( test )"
REQUIRED_USE="test? ( szip )"

# No XDR dependency: 4.4 removes the netCDF-2 interface and all XDR sources;
# there is no tirpc lookup. verified 2026-09-04
RDEPEND="virtual/zlib
	media-libs/libjpeg-turbo:=
	szip? ( virtual/szip )"
DEPEND="${RDEPEND}
	test? ( virtual/szip )"

# 4.4 is CMake-only. Removal of netCDF-2 and its headers makes the old disable
# switches obsolete; CMake also needs none of the shared/Fortran or rpath
# autotools workarounds. verified 2026-09-04

src_configure() {
	# -Werror=strict-aliasing and lto-type-mismatch. bug #862720
	append-flags -fno-strict-aliasing
	filter-lto

	if use fortran; then
		[[ $(tc-getFC) = *gfortran ]] && append-fflags -fno-range-check
		# bug #723014
		append-fflags $(test-flags-FC -fallow-argument-mismatch)
	fi

	local mycmakeargs=(
		# HDF4 ignores GNUInstallDirs; set every path to avoid multilib-strict
		# violations and /usr/cmake.
		-DHDF4_INSTALL_BIN_DIR=bin
		-DHDF4_INSTALL_LIB_DIR=$(get_libdir)
		-DHDF4_INSTALL_INCLUDE_DIR=include
		-DHDF4_INSTALL_DATA_DIR=share/hdf4
		-DHDF4_INSTALL_CMAKE_DIR=$(get_libdir)/cmake/hdf4

		-DBUILD_SHARED_LIBS=ON
		-DBUILD_STATIC_LIBS=$(usex static-libs ON OFF)
		-DBUILD_TESTING=$(usex test ON OFF)
		-DHDF4_BUILD_FORTRAN=$(usex fortran ON OFF)
		-DHDF4_ENABLE_SZIP_SUPPORT=$(usex szip ON OFF)
		-DHDF4_BUILD_TOOLS=ON
		# BUILD_TOOLS omits 17 hdf/util converters; BUILD_UTILS defaults off.
		-DHDF4_BUILD_UTILS=ON
		-DHDF4_BUILD_JAVA=OFF
		-DHDF4_BUILD_DOC=OFF
		# Install example sources as documentation; do not compile them.
		-DHDF4_BUILD_EXAMPLES=OFF
		# Prevent configure-time fetching and silent replacement of system libs.
		-DHDF4_ALLOW_EXTERNAL_SUPPORT=NO
		-DZLIB_USE_EXTERNAL=OFF
		-DJPEG_USE_EXTERNAL=OFF
		-DSZIP_USE_EXTERNAL=OFF
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Fix hard-coded libdir and invalid imported-target paths in hdf.pc.
	local private_libs="-lm -ljpeg -lz$(usex szip ' -lsz' '')"
	sed -i \
		-e "s|^libdir=.*|libdir=\${exec_prefix}/$(get_libdir)|" \
		-e "s|^Libs.private:.*|Libs.private: ${private_libs}|" \
		"${ED}/usr/$(get_libdir)/pkgconfig/hdf.pc" || die

	# 4.4 renamed release_notes and dropped its other two text files.
	dodoc release_docs/{RELEASE,HISTORY}.txt

	# Drop duplicate license and build-only CMake notes outside docdir.
	rm -r "${ED}"/usr/share/hdf4 || die

	# Upstream no longer installs its shipped example tree.
	if use examples; then
		docinto examples
		dodoc -r HDF4Examples/.
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
