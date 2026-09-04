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
# Subslot tracks the SONAME major, which 4.4.0 moves for the first time in
# this package's history: the CMake build renames libdf to libhdf and
# derives the SONAME from lt_vers.am differently than autotools did, so
# libdf.so.0 / libmfhdf.so.0 become libhdf.so.11 / libmfhdf.so.11.
# Upstream does have an install(CODE) rule meant to leave a libdf compat
# symlink, but it produces nothing here -- execute_process swallows its own
# failure -- so the old names are simply gone.
#
# The subslot is not enough for the two consumers in this tree, though.
# 4.4.0 also adds a size_t out-parameter to Vgetname and Vgetclass, and
# both sci-physics/mantid and sci-libs/nexus[hdf4] call the old
# two-argument form in their vendored NeXus napi4 sources, so they fail
# to compile rather than merely needing a relink. Both are capped at
# <sci-libs/hdf-4.4 until that code is adapted. verified 2026-09-04
SLOT="0/11"
KEYWORDS=""
# Unkeyworded deliberately, unlike every earlier version: unmask the exact
# version to install it. 4.4.0 builds and installs cleanly, but its API
# break takes both in-tree consumers with it -- sci-physics/mantid and
# sci-libs/nexus[hdf4] cap at <sci-libs/hdf-4.4 because their vendored
# NeXus napi4 sources call the two-argument Vgetname/Vgetclass. Shipping
# it ~arch would put a version into the normal upgrade path that cannot
# coexist with the packages that consume it. Restore the keywords from
# 4.3.1 once those call sites are adapted to the three-argument form.
# verified 2026-09-04
IUSE="examples fortran szip static-libs test"
RESTRICT="!test? ( test )"
REQUIRED_USE="test? ( szip )"

# No XDR dependency. 4.3.x bundled its own (mfhdf/libsrc/h4_xdr.c); 4.4.0
# has no XDR sources at all and no tirpc lookup, because XDR existed only
# to serve the netCDF-2 interface this release removes. So libtirpc stays
# out, as it has since 4.3.x, but now for a different reason.
# verified 2026-09-04
RDEPEND="virtual/zlib
	media-libs/libjpeg-turbo:=
	szip? ( virtual/szip )"
DEPEND="${RDEPEND}
	test? ( virtual/szip )"

# 4.4.0 drops the autotools build entirely -- there is no configure.ac,
# no Makefile.am and no bootstrap script left in the tarball, only
# CMakeLists.txt. So this is a port rather than a bump, and the autotools
# machinery the 4.3.1 ebuild carried goes with it:
#
#   - the three configure.ac seds that let --enable-shared survive
#     --enable-fortran. CMake builds both library kinds from the same
#     switches, so the conflict they worked around does not exist.
#   - --disable-netcdf / --disable-netcdf-tools. There is nothing left to
#     disable: RELEASE.txt records the netCDF interface being removed from
#     both C and Fortran, mfhdf/ncdump and mfhdf/ncgen are gone from the
#     source tree, and the HDF4_ENABLE_NETCDF option was deleted. The
#     hdf4_netcdf.h and hdf2netcdf.h headers 4.3.1 installed are gone with
#     it -- upstream states they are no longer distributed.
#   - the config/commence.am -R -> -L rpath sed, which had no CMake
#     counterpart to begin with.
# verified 2026-09-04 against the 4.4.0 tarball

src_configure() {
	# -Werror=strict-aliasing, -Werror=lto-type-mismatch
	# https://bugs.gentoo.org/862720
	append-flags -fno-strict-aliasing
	filter-lto

	if use fortran; then
		[[ $(tc-getFC) = *gfortran ]] && append-fflags -fno-range-check
		# GCC 10 workaround, bug #723014
		append-fflags $(test-flags-FC -fallow-argument-mismatch)
	fi

	local mycmakeargs=(
		# HDF4 routes every install through its own HDF4_INSTALL_*_DIR
		# variables and never consults GNUInstallDirs, so the
		# CMAKE_INSTALL_LIBDIR that cmake.eclass sets is ignored: left
		# alone it puts libraries in /usr/lib on a multilib profile (caught
		# by multilib-strict) and the CMake package files in /usr/cmake.
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
		# Not redundant with BUILD_TOOLS, which only covers hdfls, hdfed
		# and the mfhdf four. HDF4_BUILD_UTILS defaults to OFF and gates
		# seventeen more binaries under hdf/util -- the raster, palette
		# and GIF/JPEG converters plus vshow/vmake. Leaving it off drops
		# them silently: the sources still ship, so nothing warns.
		-DHDF4_BUILD_UTILS=ON
		-DHDF4_BUILD_JAVA=OFF
		-DHDF4_BUILD_DOC=OFF
		# Upstream still ships the example sources; they are installed as
		# documentation in src_install, matching what 4.3.1 did, so there
		# is nothing to gain from compiling them.
		-DHDF4_BUILD_EXAMPLES=OFF
		# Default is already "NO", but say it: the GIT and TGZ values make
		# the configure step fetch zlib/jpeg/szip itself, which would turn
		# a green build into one that silently ignores the system copies
		# this package depends on.
		-DHDF4_ALLOW_EXTERNAL_SUPPORT=NO
		-DZLIB_USE_EXTERNAL=OFF
		-DJPEG_USE_EXTERNAL=OFF
		-DSZIP_USE_EXTERNAL=OFF
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# 4.4.0 renamed release_notes/ to release_docs/ and dropped
	# bugs_fixed.txt and misc_docs.txt from it.
	dodoc release_docs/{RELEASE,HISTORY}.txt

	# CMake installs COPYING and two of its own docs loose under
	# share/hdf4; the licence is already in ${ED}/usr/share/doc via
	# LICENSE and the CMake notes describe a build users do not run.
	rm -r "${ED}"/usr/share/hdf4 || die

	# 4.3.x dropped the install rule for the example tree; the sources are
	# still shipped under HDF4Examples/. Copy them verbatim so users still
	# get them under USE=examples.
	if use examples; then
		docinto examples
		dodoc -r HDF4Examples/.
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
