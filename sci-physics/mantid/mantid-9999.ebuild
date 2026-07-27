# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1
PYPI_NO_NORMALIZE=1
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 git-r3 cmake

DESCRIPTION="Tools to support the processing of materials-science data"
HOMEPAGE="https://www.mantidproject.org/"

EGIT_REPO_URI="https://github.com/mantidproject/mantid.git"

if [[ ${PV} = *9999* ]] ; then
	EGIT_COMMIT="HEAD"
else
	# Mantid tags drop Gentoo's underscore in prerelease components:
	# PV 6.15.0.4_rc1 -> tag v6.15.0.4rc1.
	EGIT_COMMIT=v${PV/_/}
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
# This tracks upstream HEAD, which is now Qt6. main sets
# MANTID_QT_VERSION to 6 unconditionally - the per-platform default that
# 6.16.1.1 introduced was removed again by "Move Windows and macOs to
# Qt6" (#41896, 2026-07-27), so there is no platform where HEAD still
# builds Qt5 by default. The value is pinned in src_configure anyway, so
# the toolkit cannot change under a rebuild.
#
# The Qt5 packaging notes this ebuild used to carry are gone with it: the
# QT_DISABLE_DEPRECATED flag no longer matters, because the Qt-5.15-era
# APIs it governed (QMutex::Recursive and friends) are not compiled at
# all under Qt6.
#
# The earlier HDF4-probe blocker (Gentoo bug 942866) is resolved by this
# overlay's sci-libs/hdf-4.2.16. Install lands ~224 MiB under
# /opt/mantid/{bin,lib,lib64,plugins,instrument,scripts}.
#
# Verification here is inherited, not fresh: the identical Qt6 dependency
# set and configure arguments were run through the full
# unpack/prepare/configure/compile/install pipeline on 2026-07-27 against
# the 6.16.1.1 tag (gcc-16, Boost-1.90, Qt-6.11.1, Python 3.13). HEAD
# moves, so re-verify on each rebuild; runtime behaviour (workbench
# launch, algorithm catalog) is still untested.
#
# Note: as of 6.16.x mantid has no GPU offload — the build system uses
# only TBB + OpenMP for parallelism, and the source tree contains no
# .cu/.cuh files or find_package(CUDA) calls. There is no `cuda` IUSE
# to add here even when nvidia-cuda-toolkit is installed.
IUSE="doc python test"
RESTRICT="!test? ( test )"

# Build-host note: sci-libs/hdf5[cxx] (below) trips hdf5's REQUIRED_USE
# at-most-one-of( cxx mpi ), so on an mpi-enabled hdf5 you also need
# USE=unsupported on sci-libs/hdf5 (the cxx+mpi combo is upstream-
# "unsupported" but builds fine). That is the only host USE-config not
# expressible as a dep atom; emerge --autounmask proposes the rest from
# the atoms (qtbase concurrent/gui/network/widgets, qttools assistant,
# qscintilla qt6, nexus cxx, and nexus' own doxygen[dot]; pyqt6 and qtpy
# already default to the flags needed). KEYWORDS is empty — unmask the
# wanted version to install.

RDEPEND="
	dev-libs/boost
	dev-util/ccache
	app-text/doxygen
	dev-cpp/eigen
	dev-cpp/gtest
	dev-python/euphonic[${PYTHON_SINGLE_USEDEP}]
	sci-libs/gsl
	sci-libs/hdf
	sci-libs/hdf5[cxx]
	dev-libs/jemalloc
	dev-libs/jsoncpp
	dev-libs/librdkafka
	dev-cpp/muParser
	sci-libs/nexus[cxx]
	dev-libs/poco
	dev-python/pyvista[${PYTHON_SINGLE_USEDEP}]
	dev-python/pyvistaqt[${PYTHON_SINGLE_USEDEP}]
	x11-libs/qscintilla[qt6(+)]
	dev-qt/qtbase:6[concurrent,gui,network,widgets]
	dev-qt/qttools:6[assistant]
	dev-cpp/tbb
	sci-libs/opencascade
	app-text/texlive-core
	media-libs/mesa
	x11-apps/mesa-progs
	dev-vcs/pre-commit
	$(python_gen_cond_dep '
		dev-python/graphviz[${PYTHON_USEDEP}]
		>=dev-python/h5py-3.2.0[${PYTHON_USEDEP}]
		dev-python/matplotlib[${PYTHON_USEDEP}]
		>=dev-python/numpy-1.22[${PYTHON_USEDEP}]
		dev-python/pip[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		>=dev-python/pydantic-2.11.4[${PYTHON_USEDEP}]
		<dev-python/pydantic-3[${PYTHON_USEDEP}]
		sci-libs/pycifrw[${PYTHON_USEDEP}]
		dev-python/pyqt6[${PYTHON_USEDEP},gui,widgets,printsupport]
		dev-python/python-dateutil[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/orsopy[${PYTHON_USEDEP}]
		dev-python/qtconsole[${PYTHON_USEDEP}]
		dev-python/qtpy[${PYTHON_USEDEP},pyqt6(-)]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/superqt[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/sphinx[${PYTHON_USEDEP}]
		dev-python/sphinx-bootstrap-theme[${PYTHON_USEDEP}]
		dev-python/toml[${PYTHON_USEDEP}]
		dev-python/versioningit[${PYTHON_USEDEP}]
		dev-python/joblib[${PYTHON_USEDEP}]
	')
	test? (
		sys-apps/pciutils
		x11-libs/libXcomposite
		x11-libs/libXcursor
		x11-libs/libXdamage
		x11-libs/libXi
		x11-libs/libXScrnSaver
		x11-libs/libXtst
		dev-util/cppcheck
		dev-util/gcovr
		dev-vcs/pre-commit[${PYTHON_SINGLE_USEDEP}]
		$(python_gen_cond_dep '
			dev-python/black[${PYTHON_USEDEP}]
		')
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

	# No qt.conf rewrite here, unlike the Qt5 ebuilds. The
	# "Prefix = ../lib/qt5" that sed targeted lives inside an if(WIN32)
	# block, so it was never reached on a Linux build, and under Qt6 it
	# sits in the PyQt5-only resource branch too. The Linux install writes
	# no qt.conf at all, so Qt resolves plugins from the system prefix,
	# which is what we want.

	# Gentoo's dev-libs/boost-1.90 ships CMake configs for most
	# components except boost_system (header-only in newer Boost,
	# no shared lib / cmake config installed). Drop `system` from
	# the required components list.
	sed -i -e 's/COMPONENTS date_time regex serialization filesystem system/COMPONENTS date_time regex serialization filesystem/' \
		buildconfig/CMake/CommonSetup.cmake || die

	# buildconfig/CMake/PythonPackageTargetFunctions.cmake runs pip in
	# two places we have to fix up:
	#
	# (a) build-time `pip install --editable .` to drop a .egg-link in
	#     the build dir for in-tree development. Needs the Gentoo flags
	#     --break-system-packages (defeat PEP 668 on the marker-tagged
	#     system Python) and --no-build-isolation (use system setuptools
	#     instead of fetching from pypi, which the network sandbox blocks
	#     anyway). Both flags also belong on (b).
	#
	# (b) install-time `pip install <SRCDIR>` invoked from an install(
	#     CODE ...) block. Same flags as (a), plus --prefix and --root so
	#     pip honours portage's DESTDIR. Without --root=\$ENV{DESTDIR}
	#     the install-time pip silently fails (PEP 668) or leaks into
	#     /usr/lib/python.../site-packages on the build host instead of
	#     landing in ${ED}/opt/mantid/lib/python.../site-packages, which
	#     is why the in-tree Python wrappers (mantid/__init__.py,
	#     mantid.simpleapi, the whole workbench/ package, etc.) never
	#     made it into the merged install.
	#
	# Plus: dev-python/vcs-versioning is installed system-wide and auto-
	# hooks every setuptools build via an entry-point. Its git-based
	# file finder (vcs_versioning/_file_finders/_git.py) runs `git
	# rev-parse HEAD` in the source tree. Under portage's install phase
	# pip runs as root while the source is owned by the portage build
	# user; git refuses with "dubious ownership" and the file finder
	# raises SystemExit, killing pip metadata generation. The finder
	# checks SETUPTOOLS_SCM_IGNORE_DUBIOUS_OWNER and gracefully returns
	# None if it is set, letting setuptools' default file discovery
	# take over. SETUPTOOLS_SCM_PRETEND_VERSION isn't strictly needed
	# here since mantid's setup.py reads MANTID_VERSION_STR directly,
	# but we still set it to keep vcs-versioning's version-detection
	# hook from re-entering git later.
	sed -i \
		-e 's|-m pip install --editable . --ignore-installed --no-deps|-m pip install --editable . --ignore-installed --no-deps --break-system-packages --no-build-isolation|' \
		-e 's|python -m pip install ${CMAKE_CURRENT_SOURCE_DIR} --disable-pip-version-check --upgrade --no-deps --ignore-installed --no-cache-dir -vvv|python -m pip install ${CMAKE_CURRENT_SOURCE_DIR} --disable-pip-version-check --upgrade --no-deps --ignore-installed --no-cache-dir --break-system-packages --no-build-isolation --prefix=${CMAKE_INSTALL_PREFIX} --root=\\$ENV{DESTDIR} -vvv|' \
		-e 's|MANTID_VERSION_STR=${_version_str}|MANTID_VERSION_STR=${_version_str} SETUPTOOLS_SCM_PRETEND_VERSION=${_version_str} SETUPTOOLS_SCM_IGNORE_DUBIOUS_OWNER=1|g' \
		buildconfig/CMake/PythonPackageTargetFunctions.cmake || die

	cmake_src_prepare
}

src_configure() {
	python_setup
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${MY_PREFIX}"
		-DENABLE_DOCS=$(usex doc)
		# Pin the toolkit rather than inheriting upstream's default, which
		# has already moved twice in a month. HEAD is Qt6 everywhere now,
		# but pinning keeps a rebuild from silently relinking.
		-DMANTID_QT_VERSION=6
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Upstream ships two launchers shaped for conda layout:
	#   * launch_mantidworkbench checks $CONDA_PREFIX and aborts otherwise
	#   * launch_mantidworkbench.standalone hardcodes ${INSTALLDIR}/bin/python
	# Neither matches a Gentoo /opt install. Drop the conda one outright
	# and rewrite the standalone to use the system Python plus a PYTHONPATH
	# that includes our site-packages dir.
	rm "${ED}${MY_PREFIX}/bin/launch_mantidworkbench" || die
	local sp_dir="${MY_PREFIX}/lib/${EPYTHON}/site-packages"
	sed -i \
		-e "s|\${INSTALLDIR}/bin/python|${EPYTHON}|" \
		-e "s|LOCAL_PYTHONPATH=\${INSTALLDIR}/bin:\${INSTALLDIR}/lib:\${INSTALLDIR}/plugins|LOCAL_PYTHONPATH=${sp_dir}:\${INSTALLDIR}/bin:\${INSTALLDIR}/lib:\${INSTALLDIR}/plugins|" \
		"${ED}${MY_PREFIX}/bin/launch_mantidworkbench.standalone" || die

	# Wire /opt/mantid into PATH, LDPATH, and PYTHONPATH via env.d so
	# `import mantid` etc. work in any shell after `env-update && source
	# /etc/profile` (or a new shell). PYTHONPATH covers:
	#   * site-packages — the Python wrappers (mantid, mantidqt, workbench)
	#   * bin           — Mantid.properties (mantid resolves bin-relative
	#                     paths from sys.path entries via _bin_dirs())
	#   * plugins       — algorithm/qt6 .so plugins enumerated at startup
	newenvd - 99mantid <<-EOF
		PATH=${MY_PREFIX}/bin
		ROOTPATH=${MY_PREFIX}/bin
		LDPATH=${MY_PREFIX}/lib
		PYTHONPATH=${sp_dir}:${MY_PREFIX}/bin:${MY_PREFIX}/plugins
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
	elog
	elog "This build links Qt6, matching upstream HEAD. QtPy already"
	elog "defaults to PyQt6, so QT_API no longer has to be set by hand -"
	elog "earlier Qt5 builds of this package needed QT_API=pyqt5 and that"
	elog "override should now be dropped. The full invocation:"
	elog
	elog "    env LD_PRELOAD=/usr/lib64/libtbbmalloc_proxy.so.2 \\"
	elog "        PYTHONPATH=${MY_PREFIX}/lib/${EPYTHON}/site-packages:${MY_PREFIX}/bin:${MY_PREFIX}/plugins \\"
	elog "        ${MY_PREFIX}/bin/workbench"
	elog
	elog "After 'env-update && source /etc/profile' the PYTHONPATH and"
	elog "LD_PRELOAD pieces simplify to:"
	elog
	elog "    ${MY_PREFIX}/bin/workbench"
	elog
	elog "(LD_PRELOAD of libtbbmalloc_proxy is a perf optimisation; the"
	elog "shipped launcher ${MY_PREFIX}/bin/launch_mantidworkbench.standalone"
	elog "sets it for you and is the recommended entry point.)"
}
