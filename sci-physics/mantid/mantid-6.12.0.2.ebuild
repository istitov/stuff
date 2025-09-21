# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
#PYTHON_COMPAT=( python3_{9..12} )
PYTHON_COMPAT=( python3_11 )
PYPI_NO_NORMALIZE=1
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 git-r3 cmake multilib

DESCRIPTION="Tools to support the processing of materials-science data"
HOMEPAGE="https://www.mantidproject.org/"
#SRC_URI="https://github.com/mantidproject/mantid/archive/v${PV}.tar.gz -> ${P}.tar.gz"

EGIT_REPO_URI="https://github.com/mantidproject/mantid.git"
EGIT_REPO_URI_SPAN="https://github.com/tcbrindle/span.git"
EGIT_REPO_URI_MSLICE="https://github.com/mantidproject/mslice.git"
EGIT_REPO_URI_PYSTOG="https://github.com/neutrons/pystog.git"
EGIT_REPO_URI_GTEST="https://github.com/google/googletest.git/"

if [[ ${PV} = *9999* ]] ; then
	EGIT_COMMIT="HEAD"
else
	EGIT_COMMIT=v${PV}
fi 

EGIT_CLONE_TYPE="single"

LICENSE="GPL-v3"
SLOT="0"
KEYWORDS=""
#~amd64 #work in progress
IUSE="doc python test"

#hdf5>=1.12,<1.13
#libopenblas!=0.3.23,!=0.3.24,!=0.3.25
#<dev-python/numpy-1.25[${PYTHON_USEDEP}]

#???  occt
#qt-gtk-platformtheme
# - qt=5.15.8 # Avoid unexpected qt upgrades
#mesa/opengl
#???gxx_linux
#libglu

RDEPEND="
	dev-libs/boost
	dev-util/ccache
	app-text/doxygen
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
#	sys-devel/gcc:13[objc,objc-gc,objc++] #didbt help

BDEPEND="
	dev-build/cmake
	dev-build/ninja
"

DEPEND="${BDEPEND}
	${RDEPEND}
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

src_unpack() {
	git-r3_src_unpack
	
	EGIT_COMMIT="HEAD"

	EGIT_REPO_URI=${EGIT_REPO_URI_SPAN}
	EGIT_CHECKOUT_DIR=${WORKDIR}/${P}/_deps/span-src
	#span-subbuild/span-populate-prefix/src/span-populate-stamp/span-populate-download
	git-r3_src_unpack

	EGIT_REPO_URI=${EGIT_REPO_URI_MSLICE}
	EGIT_CHECKOUT_DIR=${WORKDIR}/${P}/scripts/ExternalInterfaces/src/mslice
	git-r3_src_unpack

	EGIT_REPO_URI=${EGIT_REPO_URI_PYSTOG}
	EGIT_CHECKOUT_DIR=${WORKDIR}/${P}/new_git/pystog
	git-r3_src_unpack
	
	EGIT_REPO_URI=${EGIT_REPO_URI_GTEST}
	EGIT_CHECKOUT_DIR=${WORKDIR}/${P}/new_git/gtest
	git-r3_src_unpack
}

src_prepare() {
	#Disable GoogleTest
	#rm -rf ${S}/buildconfig/CMake/GoogleTest.cmake || die
	
	#Enable GoogleTest
	sed -i -r "s!https://github.com/google/googletest.git!$WORKDIR/$P/new_git/gtest!" buildconfig/CMake/GoogleTest.cmake || die
	
	#Rename opencascade and links
	sed -i -e 's:/OpenCASCADE:/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die
	sed -i -e 's:/opt/opencascade/inc:/usr/include/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die
	sed -i -e 's:/opt/opencascade/lib64:/usr/lib64/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die
	
	#Disable Span
	#sed -i -e 's:include(Span):#include(Span):' buildconfig/CMake/CommonSetup.cmake || die
	#rm -rf ${S}/buildconfig/CMake/Span.cmake || die
	
	#Let Span be, but in a local repo
	sed -i -r "s!https://github.com/tcbrindle/span.git!$WORKDIR/$P/_deps/span-src!" buildconfig/CMake/Span.cmake || die
	###echo 'fake timestamp' >> ${S}/_deps/span-subbuild/span-populate-prefix/src/span-populate-stamp/span-populate-gitclone-lastrun.txt || die
	
	#Let mslice be
	sed -i -r "s!https://github.com/mantidproject/mslice.git!$WORKDIR/$P/scripts/ExternalInterfaces/src/mslice!" scripts/ExternalInterfaces/CMakeLists.txt || die
	
	#Let PyStog be
	sed -i -r "s!https://github.com/neutrons/pystog.git!$WORKDIR/$P/new_git/pystog!" buildconfig/CMake/PyStoG.cmake || die
	
	#Bugfix
	sed -iez 's:configure_package_config_file(:include(CMakePackageConfigHelpers)\nconfigure_package_config_file(:' Framework/CMakeLists.txt || die
	
	#Bugfix; works for gcc:13
	sed -iez 's:#include <utility>:#include <utility>\n#include <stdint.h>:' Framework/Parallel/src/IO/Chunker.cpp || die
	#That might be a better option... or not 
	#sed -iez 's:#include <utility>:#include <utility>\n#include <limits.h>:' Framework/Parallel/src/IO/Chunker.cpp || die
	#sed -ie 's!return UINT64_MAX;!std::numeric_limits<uint64_t>::max();!' Framework/Parallel/src/IO/Chunker.cpp || die
	
	#Bugfix; works for gcc:13
	sed -iez 's:#include <vector>:#include <vector>\n#include <stdexcept>:' Framework/API/inc/MantidAPI/PreviewManager.h || die
	
	#Bugfix (Py3.11 related, does not work)
	#sed -iez 's:#include <stdexcept>:#include <stdexcept>\n#include <internal/pycore_frame.h>\n#include <iostream>:' Framework/PythonInterface/core/src/ErrorHandling.cpp || die
	#Bugfix
	sed -ie 's!../lib/qt5\n\n!../lib64/qt5\n\n;!' qt/applications/workbench/CMakeLists.txt || die
	
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

#pkg_preinst() {
#	rm -rf ${D}/lib64
#	mv -R ${D}/lib ${D}/lib64
#}
