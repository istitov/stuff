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
	# Tags omit Gentoo's prerelease underscore (for example, _rc1 -> rc1).
	EGIT_COMMIT=v${PV/_/}
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
# Qt5 build/install and workbench verified 2026-07-05 with GCC 16, Boost 1.90,
# and Python 3.13. This release needs neither QtWebEngine nor a deprecation fix.
# Mantid has no GPU offload; TBB and OpenMP are its only parallel backends.
IUSE="doc python test"
RESTRICT="!test? ( test )"

# hdf5[cxx,mpi] additionally needs hdf5[unsupported], which cannot be
# expressed on the dependency atom. KEYWORDS is empty; unmask to install.
RDEPEND="
	dev-libs/boost
	dev-util/ccache
	app-text/doxygen
	dev-cpp/eigen
	dev-cpp/gtest
	dev-python/euphonic[${PYTHON_SINGLE_USEDEP}]
	sci-libs/gsl
	<sci-libs/hdf-4.4:=
	sci-libs/hdf5[cxx]
	dev-libs/jemalloc
	dev-libs/jsoncpp
	dev-libs/librdkafka
	dev-cpp/muParser
	sci-libs/nexus[cxx]
	dev-libs/poco
	dev-python/pyvista[${PYTHON_SINGLE_USEDEP}]
	dev-python/pyvistaqt[${PYTHON_SINGLE_USEDEP}]
	x11-libs/qscintilla[qt5(-)]
	dev-qt/qtconcurrent:5
	dev-qt/qtgui:5
	dev-qt/qthelp:5
	dev-qt/qtnetwork:5
	dev-qt/qtprintsupport:5
	dev-qt/qtsql:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
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
		dev-python/pyqt5[${PYTHON_USEDEP},gui,widgets,printsupport]
		dev-python/python-dateutil[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/orsopy[${PYTHON_USEDEP}]
		dev-python/qtconsole[${PYTHON_USEDEP}]
		dev-python/qtpy[${PYTHON_USEDEP},pyqt5(-)]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/superqt[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/sphinx[${PYTHON_USEDEP}]
		dev-python/sphinx-bootstrap-theme[${PYTHON_USEDEP}]
		dev-python/toml[${PYTHON_USEDEP}]
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

# versioningit runs directly from CMake against the git-r3 checkout, so
# ::gentoo's GitHub-archive limitation does not apply. Revisit if last-rited.
# verified 2026-08-31
BDEPEND="
	dev-build/cmake
	dev-build/ninja
	$(python_gen_cond_dep '
		dev-python/versioningit[${PYTHON_USEDEP}]
	')
"

DEPEND="${BDEPEND}
	${RDEPEND}
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

# Upstream installs non-FHS top-level data directories; keep its monolithic
# layout under /opt instead of rewriting every path.
MY_PREFIX="/opt/mantid"

src_prepare() {
	# Apply the obsolete WebWidgets probe patch only while its target remains.
	if grep -q 'Prefer WebEngineWidgets over WebkitWidgets' \
			qt/widgets/common/CMakeLists.txt 2>/dev/null; then
		eapply "${FILESDIR}/${PN}-no-qt5-webwidgets.patch"
	fi

	# Retarget OpenCascade's finder from upstream's /opt path to Gentoo's path.
	sed -i -e 's:/OpenCASCADE:/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die
	sed -i -e 's:/opt/opencascade/inc:/usr/include/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die
	sed -i -e 's:/opt/opencascade/lib64:/usr/lib64/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die

	# Fix GCC 13+ include hygiene.
	sed -iez 's:#include <vector>:#include <vector>\n#include <stdexcept>:' \
		Framework/API/inc/MantidAPI/PreviewManager.h || die

	# The generated relative Qt5 prefix is empty under /opt; use system plugins.
	sed -iez 's!../lib/qt5\n\n!/usr/lib64/qt5\n\n!' \
		qt/applications/workbench/CMakeLists.txt || die

	# boost_system is header-only and has no Gentoo CMake component.
	sed -i -e 's/COMPONENTS date_time regex serialization filesystem system/COMPONENTS date_time regex serialization filesystem/' \
		buildconfig/CMake/CommonSetup.cmake || die

	# Make both pip calls offline and PEP-668-safe; route installation through
	# DESTDIR. Suppress vcs-versioning's unsafe-ownership Git probe because
	# Mantid already supplies the version.

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
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Replace conda-only launchers with a system-Python /opt wrapper.
	rm "${ED}${MY_PREFIX}/bin/launch_mantidworkbench" || die
	local sp_dir="${MY_PREFIX}/lib/${EPYTHON}/site-packages"
	sed -i \
		-e "s|\${INSTALLDIR}/bin/python|${EPYTHON}|" \
		-e "s|LOCAL_PYTHONPATH=\${INSTALLDIR}/bin:\${INSTALLDIR}/lib:\${INSTALLDIR}/plugins|LOCAL_PYTHONPATH=${sp_dir}:\${INSTALLDIR}/bin:\${INSTALLDIR}/lib:\${INSTALLDIR}/plugins|" \
		"${ED}${MY_PREFIX}/bin/launch_mantidworkbench.standalone" || die

	# Export PATH/LDPATH, but keep PYTHONPATH process-local: a global value
	# polluted unrelated Python builds. Use the wrapper for imports.
	newenvd - 99mantid <<-EOF
		PATH=${MY_PREFIX}/bin
		ROOTPATH=${MY_PREFIX}/bin
		LDPATH=${MY_PREFIX}/lib
	EOF

	# Scope Mantid's Python paths to the wrapper process.
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
	elog "Mantid is Qt5-only. QtPy defaults to PyQt6 in ::gentoo, which"
	elog "is missing Qt5-era widgets mantid relies on. Set QT_API=pyqt5"
	elog "in the environment when launching. The full invocation:"
	elog
	elog "    env QT_API=pyqt5 \\"
	elog "        LD_PRELOAD=/usr/lib64/libtbbmalloc_proxy.so.2 \\"
	elog "        PYTHONPATH=${MY_PREFIX}/lib/${EPYTHON}/site-packages:${MY_PREFIX}/bin:${MY_PREFIX}/plugins \\"
	elog "        ${MY_PREFIX}/bin/workbench"
	elog
	elog "(LD_PRELOAD of libtbbmalloc_proxy is a perf optimisation; the"
	elog "shipped launcher ${MY_PREFIX}/bin/launch_mantidworkbench.standalone"
	elog "sets it for you and is the recommended entry point.)"
}
