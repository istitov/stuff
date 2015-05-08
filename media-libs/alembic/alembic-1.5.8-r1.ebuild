# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/alembic/alembic-1.5.8-r1.ebuild,v 10 2015/05/06 00:00:00 perestoronin Exp $

# TODO: replace the alembic_bootstrap.py with proper gentoo methods (cmake eclass)

EAPI=5
PYTHON_COMPAT=( python2_7 )
#CMAKE_REMOVE_MODULES="yes"
#CMAKE_REMOVE_MODULES_LIST="AlembicBoost AlembicPython"

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
	sed -i -e "s/python2.5/python2.7/g" build/RunPythonTest
	sed -i -e "s/2.6/2.7/g" -e "s/26/27/g" build/AlembicPython.cmake
	sed -i -e "s:boost-1_42/boost:boost:g" build/AlembicBoost.cmake
	sed -i -e "s/2.6/2.7/g" -e "s/26/27/g" -e 's:/${LIBPYTHON}/config::g' python/PyAlembic/CMakeLists.txt
	sed -i -e "/AlembicBoost.cmake/d" CMakeLists.txt
	export LIBPYTHON_VERSION=2.7
	export Boost_VERSION=1.58.0
	export BOOST_ROOT=/usr/include
#	export BOOST_LIBRARYDIR="/usr/${get_libdir}"
#	export BOOST LIBRARIES="/usr/${get_libdir}/libboost_python-2.7.so"
	export PYILMBASE_ROOT=/usr/lib
	export ALEMBIC_BOOST_FOUND=1
	export ALEMBIC_PYTHON_LIBRARY="libpython2.7.so"
	export BOOST_PYTHON_LIBRARY="libboost_python-2.7.so"
}

src_configure() {
#	die
	cmake-utils_src_configure
	echo "done"
#	die
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}
