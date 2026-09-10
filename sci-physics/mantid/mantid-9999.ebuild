# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# main's pyproject.toml requires Python >=3.13. verified 2026-09-10
PYTHON_COMPAT=( python3_{13,14} )
DISTUTILS_SINGLE_IMPL=1
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
# HEAD is Qt6-only and requires Python 3.13. It includes the tagged release's
# Python port, while the HDF 4.4 NeXus patch remains conditionally applicable.
# Configure-checked at 737f77e15ec on 2026-09-10; dependency coverage follows
# the fully built 6.16.1.1-r1 image. No CUDA integration exists.
IUSE="test"
RESTRICT="!test? ( test )"

# hdf5[cxx,mpi] additionally needs hdf5[unsupported].
# lz4 is required by the GUI crash handler. Omit unavailable pystack and
# quickBayes; only their crash/algorithm paths degrade.
# Runtime atoms mirror the tagged installed NEEDED set; Mantid vendors NeXus.
RDEPEND="
	dev-python/euphonic[${PYTHON_SINGLE_USEDEP}]
	sci-libs/gsl:=
	>=sci-libs/hdf-4.4:=
	sci-libs/hdf5:=[cxx]
	dev-libs/jsoncpp:=
	dev-libs/librdkafka:=
	dev-cpp/muParser:=
	dev-libs/openssl:=
	dev-libs/poco:=[crypt,net,util,xml]
	dev-python/pyvista[${PYTHON_SINGLE_USEDEP}]
	dev-python/pyvistaqt[${PYTHON_SINGLE_USEDEP}]
	x11-libs/qscintilla:=[qt6(+)]
	>=dev-qt/qtbase-6.11:6[concurrent,gui,network,opengl,widgets,xml]
	>=dev-qt/qttools-6.11:6[assistant]
	dev-cpp/tbb:=
	sci-libs/opencascade:=
	virtual/glu
	virtual/opengl
	$(python_gen_cond_dep '
		dev-libs/boost:=[python,${PYTHON_USEDEP}]
		>=dev-python/h5py-3.2.0[${PYTHON_USEDEP}]
		dev-python/matplotlib[${PYTHON_USEDEP}]
		>=dev-python/numpy-2.0[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		>=dev-python/pydantic-2.11.4[${PYTHON_USEDEP}]
		<dev-python/pydantic-3[${PYTHON_USEDEP}]
		sci-libs/pycifrw[${PYTHON_USEDEP}]
		dev-python/pyqt6[${PYTHON_USEDEP},gui,widgets,printsupport]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/orsopy[${PYTHON_USEDEP}]
		dev-python/qtconsole[${PYTHON_USEDEP}]
		dev-python/qtpy[${PYTHON_USEDEP},pyqt6(-)]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/superqt[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/toml[${PYTHON_USEDEP}]
		dev-python/joblib[${PYTHON_USEDEP}]
		dev-python/lz4[${PYTHON_USEDEP}]
	')
"

# dev-python/versioningit is deprecated in ::gentoo, and that deprecation
# deliberately does NOT apply here. ::gentoo's rationale is that versioningit
# "does not provide any support for building via GitHub archives" -- but this
# ebuild inherits git-r3 and builds from a real checkout, so the VCS metadata
# versioningit needs is present.
#
# It is also not a PEP 517 backend here: mantid's pyproject.toml declares no
# [build-system] at all, only [tool.versioningit.*] config, and
# buildconfig/CMake/VersionNumber.cmake runs `${Python_EXECUTABLE} -m versioningit`
# as a build step. Its own comment says the implementation "assumes the build is
# run from a Git repository". Replacing it with setuptools-scm would mean
# patching that CMake module and reimplementing the version derivation that
# feeds mantid's PEP440 check and its user-visible version string -- upstream
# divergence with no functional gain.
#
# Revisit if ::gentoo moves versioningit from deprecated to last-rited; that,
# not the deprecation itself, is what would break this. verified 2026-08-31.
BDEPEND="
	dev-build/cmake
	dev-build/ninja
	$(python_gen_cond_dep '
		dev-python/pip[${PYTHON_USEDEP}]
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/versioningit[${PYTHON_USEDEP}]
	')
"

# gtest is found unconditionally and needed to configure, but is not
# linked into the installed image.
DEPEND="${RDEPEND}
	dev-cpp/eigen
	dev-cpp/gtest
	test? (
		sys-apps/pciutils
		x11-libs/libXcomposite
		x11-libs/libXcursor
		x11-libs/libXdamage
		x11-libs/libXi
		x11-libs/libXScrnSaver
		x11-libs/libXtst
	)
"

# Install under /opt rather than /usr: upstream's CMake drops data into
# top-level /usr children (instrument/, plugins/, scripts/) that aren't
# FHS-compliant, and mantid is distributed monolithically. A single /opt
# prefix matches that shape and avoids a whole class of path-rewriting
# patches.
MY_PREFIX="/opt/mantid"

src_prepare() {
	# The vendored NeXus C API still makes HDF 4.3's two-argument
	# Vgetname and Vgetclass calls, byte-identical to 6.16.1.1's, so
	# that release's HDF 4.4 patch applies. It is applied only while
	# those calls are there, so an upstream fix does not break the
	# build. verified 2026-09-10
	if grep -q 'Vgetclass(groupID, classText);' \
			Framework/LegacyNexus/src/napi4.cpp; then
		eapply "${FILESDIR}/${PN}-6.16.1.1-hdf-4.4.patch"
	fi

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
	sed -i -e 's:#include <vector>:#include <vector>\n#include <stdexcept>:' \
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
		# The docs need mantid_sphinx_theme, which no Gentoo
		# repo ships, so they stay off rather than sit behind a
		# doc flag that could never build. verified 2026-09-10
		-DENABLE_DOCS=OFF
		# Both default ON. USE_CCACHE wraps every compile in
		# ccache whenever one is installed, regardless of
		# FEATURES, and ENABLE_PRECOMMIT stops configure without
		# pre-commit and otherwise runs `pre-commit install` in
		# the source checkout.
		-DENABLE_PRECOMMIT=OFF
		-DUSE_CCACHE=OFF
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

	# Pin the Qt binding the launcher hands to qtpy. qtpy resolves it as
	# os.environ.get("QT_API", "pyqt5") and only falls through to PyQt6
	# when PyQt5 cannot be imported - it does NOT prefer the newest
	# available. mantidqt then loads a toolkit-specific extension selected
	# by that same variable (_commonqt5 vs _commonqt6), and only the one
	# matching MANTID_QT_VERSION is built. So on any host that also has
	# dev-python/pyqt5 installed - which every Qt5 mantid pulls in, and
	# which this overlay still ships - a Qt6 workbench would otherwise
	# select PyQt5 and abort with "No module named 'mantidqt._commonqt5'".
	# ${QT_API:-...} keeps an explicit user override working.
	# verified 2026-07-27
	local qt_api=pyqt6
	sed -i \
		-e "s|\${INSTALLDIR}/bin/python|${EPYTHON}|" \
		-e "s|LOCAL_PYTHONPATH=\${INSTALLDIR}/bin:\${INSTALLDIR}/lib:\${INSTALLDIR}/plugins|LOCAL_PYTHONPATH=${sp_dir}:\${INSTALLDIR}/bin:\${INSTALLDIR}/lib:\${INSTALLDIR}/plugins|" \
		-e "s|^LD_PRELOAD=\${LOCAL_PRELOAD}|QT_API=\${QT_API:-${qt_api}} LD_PRELOAD=\${LOCAL_PRELOAD}|" \
		"${ED}${MY_PREFIX}/bin/launch_mantidworkbench.standalone" || die

	# Wire /opt/mantid's binaries and libraries into PATH/LDPATH via env.d.
	# PYTHONPATH is deliberately NOT exported globally: it leaks /opt/mantid's
	# site-packages into every package build's Python and broke
	# dev-qt/qtwebengine's hermetic chromium/perfetto codegen
	# (ModuleNotFoundError: No module named 'python.generators'). The workbench
	# launcher sets its own PYTHONPATH; the mantidpython wrapper below gives
	# `import mantid` for scripting without polluting the global environment.
	newenvd - 99mantid <<-EOF
		PATH=${MY_PREFIX}/bin
		ROOTPATH=${MY_PREFIX}/bin
		LDPATH=${MY_PREFIX}/lib
	EOF

	# mantidpython: run the system Python with Mantid's packages importable,
	# scoped to the invoked process only. PYTHONPATH covers site-packages (the
	# mantid/mantidqt/workbench wrappers), bin (Mantid.properties, resolved
	# bin-relative from sys.path via _bin_dirs()), and plugins (algorithm and
	# Qt .so plugins enumerated at startup).
	newbin - mantidpython <<-EOF
		#!/bin/sh
		export PYTHONPATH="${sp_dir}:${MY_PREFIX}/bin:${MY_PREFIX}/plugins\${PYTHONPATH:+:\${PYTHONPATH}}"
		exec ${EPYTHON} "\$@"
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
	elog "PATH and LDPATH are wired up via /etc/env.d/99mantid; run"
	elog "'env-update && source /etc/profile' or start a new shell first."
	elog "PYTHONPATH is deliberately NOT exported globally (it would leak"
	elog "into other packages' builds). For 'import mantid' in your own"
	elog "scripts, use the mantidpython wrapper -- system Python with"
	elog "Mantid importable, scoped to that process:"
	elog
	elog "    mantidpython yourscript.py       # or: mantidpython  (REPL)"
	elog
	local qt_api=pyqt6
	elog "This build links Qt6 and its Python layer binds"
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
	elog "(LD_PRELOAD of libtbbmalloc_proxy is a perf optimisation; the"
	elog "shipped launcher ${MY_PREFIX}/bin/launch_mantidworkbench.standalone"
	elog "sets it for you and is the recommended entry point.)"
}
