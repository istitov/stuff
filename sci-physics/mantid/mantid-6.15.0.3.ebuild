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
# ~amd64 — full src_unpack/prepare/configure/compile/install pipeline
# now verified clean against gcc-15 + Boost-1.90 + Qt-5.15.18 + Python
# 3.13. The earlier HDF4-probe blocker (Gentoo bug 942866) is resolved
# by this overlay's sci-libs/hdf-4.2.16. Install lands ~178 MiB under
# /opt/mantid/{bin,lib,lib64,plugins,instrument,scripts}; runtime
# behaviour (workbench launch, algorithm catalog) is still untested.
#
# Note: as of 6.15.x mantid has no GPU offload — the build system uses
# only TBB + OpenMP for parallelism, and the source tree contains no
# .cu/.cuh files or find_package(CUDA) calls. There is no `cuda` IUSE
# to add here even when nvidia-cuda-toolkit is installed.
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
	dev-qt/qtconcurrent:5
	dev-qt/qtgui:5
	dev-qt/qthelp:5
	dev-qt/qtnetwork:5
	dev-qt/qtprintsupport:5
	dev-qt/qtsql:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
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

# Install under /opt rather than /usr: upstream's CMake drops data into
# top-level /usr children (instrument/, plugins/, scripts/) that aren't
# FHS-compliant, and mantid is distributed monolithically. A single /opt
# prefix matches that shape and avoids a whole class of path-rewriting
# patches.
MY_PREFIX="/opt/mantid"

src_prepare() {
	# The no-qt5-webwidgets patch removes a "Prefer WebEngineWidgets
	# over WebKitWidgets" block that fatal-errors when neither is
	# available; the block is present in v6.15.0.3 but already gone
	# from upstream main. Apply only when the block exists so the
	# 9999 ebuild doesn't trip on an obsolete patch.
	if grep -q 'Prefer WebEngineWidgets over WebkitWidgets' \
			qt/widgets/common/CMakeLists.txt 2>/dev/null; then
		eapply "${FILESDIR}/${PN}-no-qt5-webwidgets.patch"
	fi

	# Gentoo's opencascade installs to /usr/{include,lib64}/opencascade
	# instead of /opt/OpenCASCADE; retarget the finder.
	sed -i -e 's:/OpenCASCADE:/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die
	sed -i -e 's:/opt/opencascade/inc:/usr/include/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die
	sed -i -e 's:/opt/opencascade/lib64:/usr/lib64/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die

	# gcc:13+ include-hygiene: PreviewManager.h transitively relied on
	# <vector> pulling in <stdexcept>; be explicit.
	sed -iez 's:#include <vector>:#include <vector>\n#include <stdexcept>:' \
		Framework/API/inc/MantidAPI/PreviewManager.h || die

	# Upstream generates a qt.conf with Prefix=../lib/qt5 (relative to
	# the bin dir). Under /opt/mantid/bin that points at an empty path;
	# force an absolute /usr/lib64/qt5 so Qt finds system plugins.
	sed -iez 's!../lib/qt5\n\n!/usr/lib64/qt5\n\n!' \
		qt/applications/workbench/CMakeLists.txt || die

	# Gentoo's dev-libs/boost-1.90 ships CMake configs for most
	# components except boost_system (header-only in newer Boost,
	# no shared lib / cmake config installed). Drop `system` from
	# the required components list.
	sed -i -e 's/COMPONENTS date_time regex serialization filesystem system/COMPONENTS date_time regex serialization filesystem/' \
		buildconfig/CMake/CommonSetup.cmake || die

	# Mantid runs `pip install --editable . --ignore-installed --no-deps`
	# for its in-tree Python packages. Two Gentoo-specific flags are
	# needed but pip reads them from env vars which don't survive the
	# cmake -> ninja -> cmake-E-env chain inside portage's sandbox
	# (verified: same env vars work through cmake -E env outside the
	# sandbox, so something in portage's build wrapping drops PIP_*).
	# Bake the flags into the command line instead:
	#   --break-system-packages: defeat PEP 668's refusal to install
	#     into a marker-tagged Python (the install only writes an
	#     .egg-link into the build dir, doesn't touch /usr).
	#   --no-build-isolation: use system dev-python/setuptools instead
	#     of pip fetching its own from pypi, which the network sandbox
	#     blocks anyway.
	local pip_orig='-m pip install --editable . --ignore-installed --no-deps'
	local pip_new="${pip_orig} --break-system-packages --no-build-isolation"
	sed -i -e "s|${pip_orig}|${pip_new}|" \
		buildconfig/CMake/PythonPackageTargetFunctions.cmake || die

	cmake_src_prepare
}

src_configure() {
	python_setup
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${MY_PREFIX}"
		-DENABLE_DOCS=$(usex doc)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Wire /opt/mantid into PATH, LDPATH, and PYTHONPATH via env.d.
	# User needs `env-update && source /etc/profile` (or a new shell)
	# after install or removal.
	newenvd - 99mantid <<-EOF
		PATH=${MY_PREFIX}/bin
		ROOTPATH=${MY_PREFIX}/bin
		LDPATH=${MY_PREFIX}/lib
		PYTHONPATH=${MY_PREFIX}/bin
	EOF
}

pkg_postinst() {
	elog "Mantid is installed under ${MY_PREFIX} rather than /usr."
	elog "Rationale: upstream's CMake install drops data into top-level"
	elog "/usr children (instrument/, plugins/, scripts/) instead of the"
	elog "FHS-compliant /usr/{lib64,share}/mantid/..., and the project is"
	elog "distributed monolithically. A single /opt prefix matches that"
	elog "shape and avoids a substantial path-rewriting patch set."
	elog
	elog "PATH, LDPATH, and PYTHONPATH are wired up via /etc/env.d/99mantid."
	elog "Run 'env-update && source /etc/profile' or start a new shell"
	elog "before invoking mantid."
}
