# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/openvdb/openvdb-3.0.0-r3.ebuild,v 1.4 2015/06/08 15:00:00 brothermechanic Exp $

EAPI="5"

PYTHON_COMPAT=( python3_4 )

inherit eutils versionator python-r1

DESCRIPTION="Libs for the efficient manipulation of volumetric data"
HOMEPAGE="http://www.openvdb.org"
MY_PV="$(replace_all_version_separators '_')"
SRC_URI="http://www.openvdb.org/download/${PN}_${MY_PV}_library.zip"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc +openvdb-compression X"

DEPEND="
	sys-libs/zlib
	>=dev-libs/boost-1.56.0
	media-libs/openexr
	>=dev-cpp/tbb-3.0
	>=dev-util/cppunit-1.10
	doc? ( >=app-doc/doxygen-1.4.7
	       >=dev-python/pdoc-0.2.4
	       >=app-text/ghostscript-gpl-8.70 )
	X? ( media-libs/glfw )
	dev-libs/jemalloc
	dev-python/numpy[${PYTHON_USEDEP}]
	openvdb-compression? ( >=dev-libs/c-blosc-1.5.2 )
	dev-libs/log4cplus"

RDEPEND="${RDEPEND}"

S="${WORKDIR}"/openvdb

PYTHON_VERSION="3.4"

src_prepare() {
#	epatch "${FILESDIR}"/fixnumpy.patch
	epatch "${FILESDIR}"/numpy_api.patch
	epatch "${FILESDIR}"/pyOpenVDBModule.cc.patch
	epatch "${FILESDIR}"/openvdb.patch
	epatch "${FILESDIR}"/use_svg.patch

	use doc || sed 's|^DOXYGEN :=|#|;s|^EPYDOC :=|#|' -i Makefile
	sed \
	-e	"s|^INSTALL_DIR :=.*|INSTALL_DIR := ${D}/usr|" \
	-e	"s|^TBB_LIB_DIR :=.*|TBB_LIB_DIR := /usr/$(get_libdir)|" \
	-e	"s|^PYTHON_VERSION := 2.6|PYTHON_VERSION := ${PYTHON_VERSION}|" \
	-e	"s|^GLFW_INCL_DIR.*|GLFW_INCL_DIR := /usr/$(get_libdir)|" \
	-e	"s|^GLFW_LIB_DIR :=.*|GLFW_LIB_DIR := /usr/$(get_libdir)|" \
	-e	"s|:= epydoc|:= pdoc|" \
	-e	"s|--html -o|--html --html-dir|" \
	-e	"s|vdb_render vdb_test|vdb_render vdb_view vdb_test|" \
	-i Makefile
	
	if ! use X; then
		sed 's/^\(GLFW_INCL_DIR :=\).*$/\1/' -i Makefile
		sed 's/^\(GLFW_LIB_DIR :=\).*$/\1/' -i Makefile
		sed 's/^\(GLFW_LIB :=\).*$/\1/' -i Makefile
		sed 's/^\(GLFW_MAJOR_VERSION :=\).*$/\1/' -i Makefile
	fi
	
	if use openvdb-compression; then
		sed "s|^BLOSC_INCL_DIR.*|BLOSC_INCL_DIR := /usr/include|" -i Makefile
		sed "s|^BLOSC_LIB_DIR :=.*|BLOSC_LIB_DIR := /usr/$(get_libdir)|" -i Makefile
	fi
	
	sed "s|^CPPUNIT_INCL_DIR.*|CPPUNIT_INCL_DIR := /usr/include/cppunit|" -i Makefile
	sed "s|^CPPUNIT_LIB_DIR :=.*|CPPUNIT_LIB_DIR := /usr/$(get_libdir)|" -i Makefile
	
}

src_compile() {
	emake clean
	prefix="/usr"
	emake -s \
	HFS="${prefix}" \
	HT="${prefix}" \
	HDSO="${prefix}/$(get_libdir)" \
	LIBOPENVDB_RPATH= \
	PYTHON_INCL_DIR="${prefix}/include/python${PYTHON_VERSION}" \
	PYCONFIG_INCL_DIR="${prefix}/include/python${PYTHON_VERSION}" \
	NUMPY_INCL_DIR="${prefix}/$(get_libdir)/python${PYTHON_VERSION}/site-packages/numpy/core/include/numpy" \
	BOOST_PYTHON_LIB="-lboost_python-${PYTHON_VERSION}" \
	rpath=no shared=yes || die "emake failed"
}

src_install(){
	emake DESTDIR="${D}/usr" install
	insinto /usr/include
	#doins ${FILESTDIR}/openvdb_capi.h
}
