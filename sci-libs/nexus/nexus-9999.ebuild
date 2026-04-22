# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 java-pkg-opt-2

DESCRIPTION="Data format for neutron and x-ray scattering data"
HOMEPAGE="https://www.nexusformat.org/"
EGIT_REPO_URI="https://github.com/nexusformat/code.git"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE="cxx hdf4 +hdf5 java"

REQUIRED_USE="|| ( hdf4 hdf5 )"

RDEPEND="
	dev-libs/libxml2
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
	java-pkg-opt-2_src_prepare
	cmake_src_prepare
}

src_configure() {
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
