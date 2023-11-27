# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{9..12} )
PYPI_NO_NORMALIZE=1
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 git-r3 cmake 

DESCRIPTION="Tools to support the processing of materials-science data"
HOMEPAGE="https://www.mantidproject.org/"
#SRC_URI="https://github.com/mantidproject/mantid/archive/v${PV}.tar.gz -> ${P}.tar.gz"
EGIT_REPO_URI="https://github.com/mantidproject/mantid.git"
EGIT_COMMIT=v${PV}

LICENSE="GPL-v3"
SLOT="0"
KEYWORDS=""
#~amd64 #work in progress
IUSE="doc python test"

#hdf5>=1.12,<1.13
#libopenblas!=0.3.23,!=0.3.24,!=0.3.25
#<dev-python/numpy-1.25[${PYTHON_USEDEP}]

#sci-libs/nexus ::sciense!!!
#???  occt
#qt-gtk-platformtheme
# - qt=5.15.8 # Avoid unexpected qt upgrades
#mesa/opengl
#???gxx_linux
#libglu

#nofetch - gtest
#nofetch - span (https://github.com/tcbrindle/span)
RDEPEND="
	dev-libs/boost
	dev-util/ccache
	app-doc/doxygen
	dev-cpp/eigen
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
	=sci-libs/pycifrw-4.4.1[${PYTHON_USEDEP}]
	dev-python/PyQt5[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	x11-libs/qscintilla
	dev-qt/qtbase
	dev-python/qtconsole[${PYTHON_USEDEP}]
	dev-python/QtPy[${PYTHON_USEDEP}]
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
	dev-util/cmake
	dev-util/ninja
"

DEPEND="${BDEPEND}
	${RDEPEND}
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

src_prepare() {
	rm -rf ${S}/buildconfig/CMake/GoogleTest.cmake || die
	rm -rf ${S}/buildconfig/CMake/Span.cmake || die
	sed -i -e 's:/OpenCASCADE:/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die
	sed -i -e 's:/opt/opencascade/inc:/usr/include/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die
	sed -i -e 's:/opt/opencascade/lib64:/usr/lib64/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die
	sed -i -e 's:include(Span):#include(Span):' buildconfig/CMake/CommonSetup.cmake || die
	sed -iez 's:configure_package_config_file(:include(CMakePackageConfigHelpers)\nconfigure_package_config_file(:' Framework/CMakeLists.txt || die
	default
	cmake_src_prepare
}

src_configure() {
	#local mycmakeargs=(
	#	GMOCK_INCLUDE_DIR=/usr/include/gmock/
	#)
	python_setup
	cmake_src_configure
}
