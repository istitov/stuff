# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic java-pkg-opt-2

DESCRIPTION="Data format for neutron and x-ray scattering data"
HOMEPAGE="https://nexusformat.org/"
COMMIT=5b803b3a0014bd9759b3d846da3cd3c1cfafd7d5
SRC_URI="https://github.com/nexusformat/code/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}"/code-${COMMIT}

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="cxx hdf4 +hdf5 java"

REQUIRED_USE="|| ( hdf4 hdf5 )"

RDEPEND="
	dev-libs/libxml2
	media-libs/libjpeg-turbo:=
	sys-libs/readline
	hdf4? ( >=sci-libs/hdf-4.4:= )
	hdf5? (
		sci-libs/hdf5[zlib]
		virtual/zlib:=
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-text/doxygen[dot]
"

pkg_setup() {
	java-pkg-opt-2_pkg_setup
}

src_prepare() {
	xzcat "${FILESDIR}/474.patch.xz" > "${T}/474.patch" || die
	eapply "${T}/474.patch"
	eapply "${FILESDIR}/${PN}-4.4.3-hdf-4.4.patch"

	# The C++ wrapper links only HDF5 C/HL; avoid the unnecessary CXX component,
	# which conflicts with MPI-enabled HDF5. verified 2026-06-21
	sed -e 's/COMPONENTS CXX HL REQUIRED/COMPONENTS C HL REQUIRED/' \
		-i CMakeLists.txt || die

	# Raise the policy baseline for CMake 4.
	sed -i 's/cmake_minimum_required(VERSION 2.8.7)/cmake_minimum_required(VERSION 3.10)/' \
		CMakeLists.txt || die

	java-pkg-opt-2_src_prepare
	cmake_src_prepare
}

src_configure() {
	# Pin C++17; this snapshot uses allocator::allocate(n, hint), removed in C++20.
	append-cxxflags -std=gnu++17

	# Fortran bindings do not compile.
	local mycmakeargs=(
		-DENABLE_APPS=ON
		-DENABLE_CONTRIB=ON
		-DENABLE_HDF4=$(usex hdf4)
		-DENABLE_HDF5=$(usex hdf5)
		-DENABLE_MXML=NO
		-DENABLE_CXX=$(usex cxx)
		-DENABLE_FORTRAN90=NO
		-DENABLE_FORTRAN77=NO
		-DENABLE_JAVA=$(usex java)
	)
	cmake_src_configure
}
