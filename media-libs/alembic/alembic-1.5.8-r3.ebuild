# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/alembic/alembic-1.5.8-r2.ebuild,v 10 2015/05/15 00:00:00 perestoronin Exp $

EAPI=5
PYTHON_COMPAT=( python3_4 )

inherit cmake-utils eutils python-single-r1

DESCRIPTION="Alembic is an open framework for storing and sharing 3D geometry data that includes a C++ library, a file format, and client plugins and applications."
HOMEPAGE="http://alembic.io"
SRC_URI="https://github.com/alembic/alembic/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"
RDEPEND=""
DEPEND=">=dev-util/cmake-2.8
	>=dev-libs/boost-1.44
	>=media-libs/ilmbase-1.0.1
	>=sci-libs/hdf5-1.8.7
	media-libs/pyilmbase
	doc? ( >=app-doc/doxygen-1.7.3 )"

src_prepare() {
	sed -e "s:/usr/lib64/.*/config:/usr/lib64:g;s:/usr/lib/.*/config:/usr/lib:g" \
		-i python/{PyAlembic,PyAbcOpenGL}/CMakeLists.txt || die
#	sed -e "s/2.6/3.4/g;s/26/34/g;s:/usr/lib64/.*/config:/usr/lib64:g;s:/usr/lib/.*/config:/usr/lib:g" \
#		-i python/{PyAlembic,PyAbcOpenGL}/CMakeLists.txt || die

#	sed -e "/build.*.cmake/d;s/ALEMBIC_NO_TESTS FALSE/ALEMBIC_NO_TESTS TRUE/;s/ALEMBIC_NO_BOOTSTRAP FALSE/ALEMBIC_NO_BOOTSTRAP TRUE/" \
	sed -e "/build.*.cmake/d;s/ALEMBIC_NO_BOOTSTRAP FALSE/ALEMBIC_NO_BOOTSTRAP TRUE/;s:/alembic-\${VERSION}::g" \
		-i CMakeLists.txt || die

	rm -Rf build || die

#	epatch "${FILESDIR}"/SimpleAbcViewer_CMakeLists.patch
}

src_configure() {
	local mycmakeargs=(
		-DLIBPYTHON_VERSION=3.4
		-DBoost_PYTHON_LIBRARY=boost_python-3.4
		-DBoost_INCLUDE_DIRS=/usr/include/boost/
		-DBoost_FOUND=TRUE
		-DBOOST_LIBRARY_DIR=/usr/lib64
		-DALEMBIC_BOOST_FOUND=TRUE
		-DALEMBIC_BOOST_INCLUDE_PATH=/usr/include/boost/
		-DALEMBIC_BOOST_LIBRARIES=boost_python-3.4
		-DALEMBIC_PYTHON_ROOT=/usr/lib64
		-DALEMBIC_HDF5_LIBS="-lhdf5_hl -lhdf5_cpp -lhdf5_fortran -lhdf5"
		-DILMBASE_LIBRARY_DIR=/usr/lib64
		-DALEMBIC_ILMBASE_INCLUDE_DIRECTORY=/usr/include/OpenEXR
		-DALEMBIC_ILMBASE_LIBS="-lIex -lIexMath -lIlmThread -lImath -lHalf"
		-DALEMBIC_ILMBASE_IMATH_LIB=Imath
		-DALEMBIC_ILMBASE_ILMTHREAD_LIB=IlmThread
		-DALEMBIC_ILMBASE_IEX_LIB=Iex
		-DALEMBIC_ILMBASE_IEXMATH_LIB=IexMath
		-DALEMBIC_ILMBASE_HALF_LIB=Half
		-DOPENEXR_INCLUDE_PATHS=/usr/include/OpenEXR
		-DALEMBIC_OPENEXR_LIBRARIES="-lIlmImfUtil -lIlmImf"
		-DALEMBIC_PYILMBASE_INCLUDE_DIRECTORY=/usr/include/OpenEXR
		-DALEMBIC_PYILMBASE_LIBRARIES="-lPyIex -lPyImath"
		-DUSE_PRMAN=FALSE
		-DUSE_ARNOLD=FALSE
		-DUSE_MAYA=FALSE
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}
