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
	hdf4? ( sci-libs/hdf )
	hdf5? ( sci-libs/hdf5[zlib] )
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
	java-pkg-opt-2_src_prepare
	cmake_src_prepare
}

src_configure() {
	# This 2020 source snapshot uses the 2-argument std::allocator::
	# allocate(n, hint) overload (NXtranslate/nexus_retriever.cpp), which
	# is deprecated in C++17 and removed in C++20. GCC defaults to a newer
	# standard, so pin C++17 where the overload still exists.
	append-cxxflags -std=gnu++17

	# no fortran, doesn't compile
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
