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
# ~amd64 — both toolkits run the full src_unpack/prepare/configure/
# compile/install pipeline clean, verified 2026-07-27 against gcc-16 +
# Boost-1.90 + Python 3.13:
#   USE=qt6  Qt-6.11.1, 3028/3028 steps, 227 MiB, image links no libQt5
#            and carries no Qt5-named artefact. Runtime-checked too: the
#            framework runs algorithms, qtpy binds PyQt6, the
#            QScintilla-backed ScriptEditor instantiates and the workbench
#            MainWindow constructs.
#   USE=qt5  Qt-5.15.19, 3028/3028 steps, 230 MiB, image links only
#            libQt5{Core,Widgets,Gui,Xml,PrintSupport} and no Qt6 at all.
#            Compile/install only — not runtime-exercised.
#
# 6.16.1.1 added MANTID_QT_VERSION (5 or 6), so this ebuild exposes both
# toolkits as mutually exclusive USE flags rather than hardcoding one.
# Upstream's own default moved twice inside a month — 6.16.1.1 picks 6 on
# Linux but 5 on Windows/macOS, and main hardcoded 6 for every platform on
# 2026-07-27 (#41896) — so src_configure passes the version explicitly and
# never inherits the platform default.
#
# Upstream still offers Qt5 deliberately — CMakeLists.txt keeps
# `set_property(CACHE MANTID_QT_VERSION PROPERTY STRINGS 5 6)` and a real
# find_package(QT 5.15 NAMES Qt5 ... REQUIRED), and #41896 changed only
# the default — but at this tag that path does NOT build unpatched. The
# deprecation-guard rename described in src_prepare breaks it, and USE=qt5
# depends on the workaround there. Treat the predicted bitrot as already
# under way rather than hypothetical: no platform defaults to Qt5 on Linux
# any more, so upstream CI does not compile this configuration and the
# next bump may well need a fresh fix. verified 2026-07-27
#
# Everything the Qt6 path needs is in ::gentoo: qtbase-6.11.1 satisfies
# upstream's QT6_MIN_VERSION of 6.11, and QtHelp comes from
# qttools[assistant]. The Qt5 path additionally needs dev-python/pyqt5 and
# dev-python/pyqt5-sip, which ::gentoo has removed and only this overlay
# still carries — that dependency is the standing cost of keeping the flag.
#
# pyrcc5 is a build-time requirement of the Qt5 path only, and pyqt5
# covers it: qt/CMakeLists.txt resolves PYRCC5_CMD under
# `MANTID_QT_VERSION EQUAL 5` and FATAL_ERRORs when neither
# PyQt5.pyrcc_main nor a pyrcc5 binary is found. Under Qt6 that block is
# skipped entirely — PyQt6 ships no Python resource compiler, so upstream
# compiles a binary .rcc with Qt's own rcc instead.
#
# dev-python/lz4 is a hard runtime requirement on Linux specifically, and
# a clean build does not reveal it: mantidqt/dialogs/errorreports/
# run_pystack.py does a bare `if is_linux(): import lz4.frame` at module
# scope, and the workbench's exception handler imports that module during
# startup. Without it the framework and `import mantidqt` both still work
# and only the GUI fails. Upstream lists it under the Linux-only branch of
# conda/recipes/mantidworkbench/recipe.yaml. verified 2026-07-27
#
# The `pystack` upstream lists beside it is NOT declared here: it is in no
# Gentoo repo, and run_pystack.py only ever shells out to it
# (`["pystack", "core", ...]`) when analysing a core dump. Missing, it
# degrades crash reporting and nothing else. ipykernel is likewise not
# declared - mantid never imports it, and dev-python/qtconsole already
# requires >=ipykernel-4.1.
#
# The dev-qt/qtsql:5 the Qt5 branch carries has no Qt6 counterpart:
# mantid itself asks for no Sql component. The Qt6 build does still link
# libQt6Sql, because dev-qt/qttools[assistant] pulls
# ~dev-qt/qtbase:6[concurrent,network,sql,sqlite] for QtHelp's own
# database. Declaring sql there would duplicate a constraint qttools
# already enforces.
#
# The earlier HDF4-probe blocker (Gentoo bug 942866) is resolved by this
# overlay's sci-libs/hdf-4.2.16. Install lands ~230 MiB under
# /opt/mantid/{bin,lib,lib64,plugins,instrument,scripts}. Upstream removed
# all QtWebEngineWidgets usage in 6.15.0.4rc1 and it stays gone in 6.16.x.
#
# Note: as of 6.16.x mantid has no GPU offload — the build system uses
# only TBB + OpenMP for parallelism, and the source tree contains no
# .cu/.cuh files or find_package(CUDA) calls. There is no `cuda` IUSE
# to add here even when nvidia-cuda-toolkit is installed.
IUSE="doc python qt5 +qt6 test"
RESTRICT="!test? ( test )"

# Build-host note: sci-libs/hdf5[cxx] (below) trips hdf5's REQUIRED_USE
# at-most-one-of( cxx mpi ), so on an mpi-enabled hdf5 you also need
# USE=unsupported on sci-libs/hdf5 (the cxx+mpi combo is upstream-
# "unsupported" but builds fine). That is the only host USE-config not
# expressible as a dep atom; emerge --autounmask proposes the rest from
# the atoms (nexus cxx, nexus' own doxygen[dot], and per toolkit either
# qtbase concurrent/gui/network/widgets + qttools assistant + qscintilla
# qt6, or the dev-qt:5 set + qscintilla qt5). KEYWORDS is empty — unmask
# the wanted version to install.

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
	qt6? (
		x11-libs/qscintilla[qt6(+)]
		dev-qt/qtbase:6[concurrent,gui,network,widgets]
		dev-qt/qttools:6[assistant]
	)
	qt5? (
		x11-libs/qscintilla[qt5(-)]
		dev-qt/qtconcurrent:5
		dev-qt/qtgui:5
		dev-qt/qthelp:5
		dev-qt/qtnetwork:5
		dev-qt/qtprintsupport:5
		dev-qt/qtsql:5
		dev-qt/qtwidgets:5
		dev-qt/qtxml:5
	)
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
		qt6? ( dev-python/pyqt6[${PYTHON_USEDEP},gui,widgets,printsupport] )
		qt5? ( dev-python/pyqt5[${PYTHON_USEDEP},gui,widgets,printsupport] )
		dev-python/python-dateutil[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/orsopy[${PYTHON_USEDEP}]
		dev-python/qtconsole[${PYTHON_USEDEP}]
		qt6? ( dev-python/qtpy[${PYTHON_USEDEP},pyqt6(-)] )
		qt5? ( dev-python/qtpy[${PYTHON_USEDEP},pyqt5(-)] )
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/superqt[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/sphinx[${PYTHON_USEDEP}]
		dev-python/sphinx-bootstrap-theme[${PYTHON_USEDEP}]
		dev-python/toml[${PYTHON_USEDEP}]
		dev-python/versioningit[${PYTHON_USEDEP}]
		dev-python/joblib[${PYTHON_USEDEP}]
		dev-python/lz4[${PYTHON_USEDEP}]
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

REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
	^^ ( qt5 qt6 )
"

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

	if use qt5; then
		# 6.16.1.1 renamed the deprecation guard from
		# QT_DISABLE_DEPRECATED_UP_TO (6.16.0, 6.16.1) to
		# QT_DISABLE_DEPRECATED_BEFORE, keeping the value 0x050F00. That is
		# inert under Qt6 but breaks Qt5, because Qt 5.15's qglobal.h knows
		# only the _BEFORE spelling: _UP_TO is silently ignored, while
		# _BEFORE feeds QT_DEPRECATED_SINCE(major, minor), defined as
		# QT_VERSION_CHECK(major, minor, 0) > QT_DISABLE_DEPRECATED_BEFORE.
		# For an API deprecated in 5.15 that is 0x050F00 > 0x050F00, i.e.
		# false, so everything deprecated up to AND INCLUDING 5.15 is
		# compiled out - among it QMutex::RecursionMode, which
		# WorkspaceTreeWidget.cpp still uses inside its own
		# `#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)` guard.
		#
		# Restore the spelling 6.16.1 shipped. Scoped to USE=qt5 so the
		# verified Qt6 build keeps upstream's own flag verbatim. This is
		# the same failure the 6.16.0.1 ebuild works around, re-introduced
		# by a rename rather than a value change. verified 2026-07-27
		sed -i -e 's/QT_DISABLE_DEPRECATED_BEFORE=0x050F00/QT_DISABLE_DEPRECATED_UP_TO=0x050F00/' \
			CMakeLists.txt || die
		grep -q 'QT_DISABLE_DEPRECATED_UP_TO=0x050F00' CMakeLists.txt ||
			die "deprecation-guard rename did not apply"
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

	# No qt.conf rewrite here, unlike the Qt5-only ebuilds that preceded
	# this one - and that holds for both toolkits, not just Qt6. The
	# "Prefix = ../lib/qt5" that sed targeted lives inside an if(WIN32)
	# block - true at 6.16.1 as well as here - so it was never reached on
	# a Linux build either way. The Linux install writes no qt.conf at
	# all, so Qt resolves plugins from the system prefix, which is what
	# we want.

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
		# Pass the toolkit explicitly rather than inheriting upstream's
		# default, which has already moved twice — 6.16.1.1 varies it by
		# platform and main hardcoded 6. REQUIRED_USE makes this exactly
		# one of the two.
		-DMANTID_QT_VERSION=$(usex qt6 6 5)
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

	# Pin the Qt binding the launcher hands to qtpy. qtpy resolves its
	# binding as os.environ.get("QT_API", "pyqt5") and only falls through
	# to PyQt6 when PyQt5 cannot be imported - it does NOT prefer the
	# newest available. mantidqt then loads a toolkit-specific extension
	# selected by that same variable (_commonqt5 vs _commonqt6), and only
	# the one matching MANTID_QT_VERSION is built. So on any host that also
	# has dev-python/pyqt5 installed - which every Qt5 mantid pulls in, and
	# which this overlay still ships - a Qt6 workbench would otherwise
	# select PyQt5 and abort with "No module named 'mantidqt._commonqt5'".
	# ${QT_API:-...} keeps an explicit user override working.
	# verified 2026-07-27 by launching the workbench with and without it.
	local qt_api=$(usex qt6 pyqt6 pyqt5)
	sed -i \
		-e "s|\${INSTALLDIR}/bin/python|${EPYTHON}|" \
		-e "s|LOCAL_PYTHONPATH=\${INSTALLDIR}/bin:\${INSTALLDIR}/lib:\${INSTALLDIR}/plugins|LOCAL_PYTHONPATH=${sp_dir}:\${INSTALLDIR}/bin:\${INSTALLDIR}/lib:\${INSTALLDIR}/plugins|" \
		-e "s|^LD_PRELOAD=\${LOCAL_PRELOAD}|QT_API=\${QT_API:-${qt_api}} LD_PRELOAD=\${LOCAL_PRELOAD}|" \
		"${ED}${MY_PREFIX}/bin/launch_mantidworkbench.standalone" || die

	# Wire /opt/mantid into PATH, LDPATH, and PYTHONPATH via env.d so
	# `import mantid` etc. work in any shell after `env-update && source
	# /etc/profile` (or a new shell). PYTHONPATH covers:
	#   * site-packages — the Python wrappers (mantid, mantidqt, workbench)
	#   * bin           — Mantid.properties (mantid resolves bin-relative
	#                     paths from sys.path entries via _bin_dirs())
	#   * plugins       — algorithm and Qt .so plugins enumerated at startup
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
	local qt_api=$(usex qt6 pyqt6 pyqt5)
	elog "This build links Qt$(usex qt6 6 5) and its Python layer binds"
	elog "${qt_api}. qtpy does not pick the newest binding available - it"
	elog "reads QT_API and falls back to pyqt5 - so the launcher below"
	elog "exports QT_API=${qt_api} for you. Use it rather than invoking"
	elog "the workbench directly:"
	elog
	elog "    ${MY_PREFIX}/bin/launch_mantidworkbench.standalone"
	elog
	elog "Calling ${MY_PREFIX}/bin/workbench by hand needs QT_API set"
	elog "explicitly, or mantidqt looks for the extension of whichever"
	elog "toolkit qtpy picked and aborts with a ModuleNotFoundError for"
	elog "mantidqt._commonqt5 / _commonqt6 - only _common${qt_api#py} is built:"
	elog
	elog "    env LD_PRELOAD=/usr/lib64/libtbbmalloc_proxy.so.2 \\"
	elog "        QT_API=${qt_api} \\"
	elog "        PYTHONPATH=${MY_PREFIX}/lib/${EPYTHON}/site-packages:${MY_PREFIX}/bin:${MY_PREFIX}/plugins \\"
	elog "        ${MY_PREFIX}/bin/workbench"
	elog
	elog "After 'env-update && source /etc/profile' that shortens to:"
	elog
	elog "    env QT_API=${qt_api} ${MY_PREFIX}/bin/workbench"
	elog
	elog "(LD_PRELOAD of libtbbmalloc_proxy is a perf optimisation; the"
	elog "shipped launcher ${MY_PREFIX}/bin/launch_mantidworkbench.standalone"
	elog "sets it for you and is the recommended entry point.)"
}
