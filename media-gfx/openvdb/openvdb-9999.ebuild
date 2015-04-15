# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/openvdb/openvdb-3.0.0.ebuild,v 2.0 2015/04/15 02:54:23 brothermechanic Exp $

EAPI="5"

PYTHON_COMPAT=( python2_7 )

inherit eutils versionator python-r1 git-2

DESCRIPTION="Libs for the efficient manipulation of volumetric data"
HOMEPAGE="http://www.openvdb.org"
#MY_PV="$(replace_all_version_separators '_')"
#SRC_URI="http://www.openvdb.org/download/${PN}_${MY_PV}_library.zip"
EGIT_REPO_URI="https://github.com/dreamworksanimation/openvdb.git"

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
	dev-libs/jemalloc
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-libs/log4cplus
	dev-libs/c-blosc
	media-libs/glfw
	"

RDEPEND="${RDEPEND}"

PYTHON_VERSION="2.7"

src_prepare() {
	cd openvdb
	epatch "${FILESDIR}"/use_svg.patch
	epatch "${FILESDIR}"/gentoo-GL-glfw.patch
	use doc || sed s/"DOXYGEN := doxygen"/"DOXYGEN :="/g -i Makefile && sed s/"EPYDOC := epydoc"/"EPYDOC :="/g -i Makefile
	sed \
	-e	"s|^INSTALL_DIR :=.*|INSTALL_DIR := ${D}/usr|" \
	-e	"s|^TBB_LIB_DIR :=.*|TBB_LIB_DIR := /usr/$(get_libdir)|" \
	-e	"s|^PYTHON_VERSION := 2.6|PYTHON_VERSION := ${PYTHON_VERSION}|" \
	-e	"s|^GLFW_INCL_DIR.*|GLFW_INCL_DIR := /usr/$(get_libdir)|" \
	-e	"s|^GLFW_LIB_DIR :=.*|GLFW_LIB_DIR := /usr/$(get_libdir)|" \
	-i Makefile
}

src_compile() {
	cd openvdb
	emake clean
	prefix="/usr"
	emake -s \
	HFS="${prefix}" \
	HT="${prefix}" \
	HDSO="${prefix}/$(get_libdir)" \
	LIBOPENVDB_RPATH= \
	PYCONFIG_INCL_DIR="${prefix}/include/python${PYTHON_VERSION}" \
	NUMPY_INCL_DIR="${prefix}/$(get_libdir)/python${PYTHON_VERSION}/site-packages/numpy/core/include/numpy" \
	PYTHON_VERSION="${PYTHON_VERSION}" \
	BOOST_PYTHON_LIB="-lboost_python-${PYTHON_VERSION}" \
	rpath=no shared=yes || die "emake failed"
}

src_install() {
	cd openvdb
	emake -s DESTDIR="${D}/usr" install
}
