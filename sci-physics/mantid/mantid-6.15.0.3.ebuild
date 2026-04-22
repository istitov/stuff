# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
PYPI_NO_NORMALIZE=1
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 git-r3 cmake

DESCRIPTION="Tools to support the processing of materials-science data"
HOMEPAGE="https://www.mantidproject.org/"

EGIT_REPO_URI="https://github.com/mantidproject/mantid.git"

if [[ ${PV} = *9999* ]] ; then
	EGIT_COMMIT="HEAD"
else
	EGIT_COMMIT=v${PV}
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
# ~amd64 — work in progress. Build-verified through src_configure up
# to the HDF4 probe; further configure blocked by sci-libs/hdf failing
# to compile against gcc 15 (Gentoo bug 942866). Not a mantid-side
# bug.
IUSE="doc python test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/boost
	dev-util/ccache
	app-text/doxygen
	dev-cpp/eigen
	dev-cpp/gtest
	dev-python/euphonic[${PYTHON_USEDEP}]
	dev-python/graphviz[${PYTHON_USEDEP}]
	sci-libs/gsl
	>=dev-python/h5py-3.2.0[${PYTHON_USEDEP}]
	sci-libs/hdf5
	dev-libs/jemalloc
	dev-libs/jsoncpp
	dev-libs/librdkafka
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-cpp/muParser
	sci-libs/nexus[cxx]
	>=dev-python/numpy-1.22[${PYTHON_USEDEP}]
	dev-python/pip[${PYTHON_USEDEP}]
	dev-libs/poco
	dev-python/psutil[${PYTHON_USEDEP}]
	sci-libs/pycifrw[${PYTHON_USEDEP}]
	dev-python/pyqt5[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	x11-libs/qscintilla
	dev-qt/qtbase
	dev-python/qtconsole[${PYTHON_USEDEP}]
	dev-python/qtpy[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/sphinx[${PYTHON_USEDEP}]
	dev-python/sphinx-bootstrap-theme[${PYTHON_USEDEP}]
	dev-cpp/tbb
	sci-libs/opencascade
	app-text/texlive-core
	dev-python/toml[${PYTHON_USEDEP}]
	dev-python/versioningit[${PYTHON_USEDEP}]
	dev-python/joblib[${PYTHON_USEDEP}]
	media-libs/mesa
	x11-apps/mesa-progs
	dev-vcs/pre-commit
	test? (
		sys-apps/pciutils
		x11-libs/libXcomposite
		x11-libs/libXcursor
		x11-libs/libXdamage
		x11-libs/libXi
		x11-libs/libXScrnSaver
		x11-libs/libXtst
		dev-python/black[${PYTHON_USEDEP}]
		dev-util/cppcheck
		dev-util/gcovr
		dev-vcs/pre-commit[${PYTHON_USEDEP}]
	)
"

BDEPEND="
	dev-build/cmake
	dev-build/ninja
"

DEPEND="${BDEPEND}
	${RDEPEND}
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

src_prepare() {
	# Gentoo's opencascade installs to /usr/{include,lib64}/opencascade
	# instead of /opt/OpenCASCADE; retarget the finder.
	sed -i -e 's:/OpenCASCADE:/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die
	sed -i -e 's:/opt/opencascade/inc:/usr/include/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die
	sed -i -e 's:/opt/opencascade/lib64:/usr/lib64/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die

	# gcc:13+ include-hygiene: PreviewManager.h transitively relied on
	# <vector> pulling in <stdexcept>; be explicit.
	sed -iez 's:#include <vector>:#include <vector>\n#include <stdexcept>:' \
		Framework/API/inc/MantidAPI/PreviewManager.h || die

	# Upstream hardcodes lib/qt5; Gentoo amd64 is lib64/qt5.
	sed -ie 's!../lib/qt5\n\n!../lib64/qt5\n\n;!' qt/applications/workbench/CMakeLists.txt || die

	# Gentoo's dev-libs/boost-1.90 ships CMake configs for most
	# components except boost_system (header-only in newer Boost,
	# no shared lib / cmake config installed). Drop `system` from
	# the required components list.
	sed -i -e 's/COMPONENTS date_time regex serialization filesystem system/COMPONENTS date_time regex serialization filesystem/' \
		buildconfig/CMake/CommonSetup.cmake || die

	default
	cmake_src_prepare
}

src_configure() {
	python_setup
	cmake_src_configure
}
