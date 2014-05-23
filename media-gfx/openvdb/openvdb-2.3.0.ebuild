# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/openvdb/openvdb-1.2.0.ebuild,v 1.0 2014/01/30 02:54:23 brothermechanic+megabaks Exp $

EAPI="5"

PYTHON_COMPAT=( python2_7 )

inherit eutils versionator python-r1

DESCRIPTION="Libs for the efficient manipulation of volumetric data"
HOMEPAGE="http://www.openvdb.org"
MY_PV="$(replace_all_version_separators '_')"
SRC_URI="http://www.openvdb.org/download/${PN}_${MY_PV}_library.zip"
LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND="
	sys-libs/zlib
	>=dev-libs/boost-1.42.0
	media-libs/openexr
	>=dev-cpp/tbb-3.0
	>=dev-util/cppunit-1.10
	doc? ( >=app-doc/doxygen-1.4.7
	       dev-python/epydoc[${PYTHON_USEDEP}]
	       >=app-text/ghostscript-gpl-8.70 )
	( >=media-libs/glfw-2.7.5 <media-libs/glfw-3.0.3 )
	dev-libs/jemalloc
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-libs/log4cplus"

RDEPEND="${RDEPEND}"

S="${WORKDIR}/openvdb"

PYTHON_VERSION="2.7"

src_prepare() {
	epatch "${FILESDIR}"/*.patch
	use doc || sed 's|^DOXYGEN :=|#|;s|^EPYDOC :=|#|' -i Makefile
	sed \
	-e	"s|^INSTALL_DIR :=.*|INSTALL_DIR := ${D}/usr|" \
	-e	"s|^TBB_LIB_DIR :=.*|TBB_LIB_DIR := /usr/$(get_libdir)|" \
	-e	"s|^PYTHON_VERSION := 2.6|PYTHON_VERSION := ${PYTHON_VERSION}|" \
	-e	"s|^GLFW_INCL_DIR.*|GLFW_INCL_DIR := /usr/$(get_libdir)|" \
	-e	"s|^GLFW_LIB_DIR :=.*|GLFW_LIB_DIR := /usr/$(get_libdir)|" \
	-i Makefile
}

src_compile() {
	emake clean
	prefix="/usr"
	emake -s \
	HFS="${prefix}" \
	HT="${prefix}" \
	HDSO="${prefix}/$(get_libdir)" \
	LIBOPENVDB_RPATH= \
	PYCONFIG_INCL_DIR="${prefix}/include/python${PYTHON_VERSION}" \
	NUMPY_INCL_DIR="${prefix}/$(get_libdir)/python${PYTHON_VERSION}/site-packages/numpy/core/include/numpy" \
	BOOST_PYTHON_LIB="-lboost_python-${PYTHON_VERSION}" \
	rpath=no shared=yes || die "emake failed"
}

src_install() {
	emake -s DESTDIR="${D}/usr" install
}
