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
	# Tags omit Gentoo's prerelease underscore (for example, _rc1 -> rc1).
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

# CMake runs versioningit against the git-r3 checkout. Revisit if last-rited.
# Verified 2026-08-31.
BDEPEND="
	dev-build/cmake
	dev-build/ninja
	$(python_gen_cond_dep '
		dev-python/pip[${PYTHON_USEDEP}]
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/versioningit[${PYTHON_USEDEP}]
	')
"

# gtest is a configure-only dependency.
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

# Upstream installs non-FHS top-level data directories; keep its monolithic
# layout under /opt instead of rewriting every path.
MY_PREFIX="/opt/mantid"

src_prepare() {
	# Apply the HDF 4.4 API fix only while the legacy calls remain.
	if grep -q 'Vgetclass(groupID, classText);' \
			Framework/LegacyNexus/src/napi4.cpp; then
		eapply "${FILESDIR}/${PN}-6.16.1.1-hdf-4.4.patch"
	fi

	# Remove the obsolete WebEngine/WebKit preference block when present.
	if grep -q 'Prefer WebEngineWidgets over WebkitWidgets' \
			qt/widgets/common/CMakeLists.txt 2>/dev/null; then
		eapply "${FILESDIR}/${PN}-no-qt5-webwidgets.patch"
	fi

	# Retarget OpenCascade's finder to Gentoo's path.
	sed -i -e 's:/OpenCASCADE:/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die
	sed -i -e 's:/opt/opencascade/inc:/usr/include/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die
	sed -i -e 's:/opt/opencascade/lib64:/usr/lib64/opencascade:' buildconfig/CMake/FindOpenCascade.cmake || die

	# Fix GCC 13+ include hygiene.
	sed -i -e 's:#include <vector>:#include <vector>\n#include <stdexcept>:' \
		Framework/API/inc/MantidAPI/PreviewManager.h || die

	# boost_system is header-only and has no Gentoo CMake component.
	sed -i -e 's/COMPONENTS date_time regex serialization filesystem system/COMPONENTS date_time regex serialization filesystem/' \
		buildconfig/CMake/CommonSetup.cmake || die

	# Keep pip offline and PEP-668-safe, honor DESTDIR, and skip redundant Git probes.

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
		# mantid_sphinx_theme is unpackaged, so docs cannot build.
		-DENABLE_DOCS=OFF
		# Avoid implicit ccache use and pre-commit source-tree mutation.
		-DENABLE_PRECOMMIT=OFF
		-DUSE_CCACHE=OFF
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Replace conda-only launchers with a system-Python /opt wrapper.
	rm "${ED}${MY_PREFIX}/bin/launch_mantidworkbench" || die
	local sp_dir="${MY_PREFIX}/lib/${EPYTHON}/site-packages"

	# Select PyQt6 unless the user overrides qtpy.
	local qt_api=pyqt6
	sed -i \
		-e "s|\${INSTALLDIR}/bin/python|${EPYTHON}|" \
		-e "s|LOCAL_PYTHONPATH=\${INSTALLDIR}/bin:\${INSTALLDIR}/lib:\${INSTALLDIR}/plugins|LOCAL_PYTHONPATH=${sp_dir}:\${INSTALLDIR}/bin:\${INSTALLDIR}/lib:\${INSTALLDIR}/plugins|" \
		-e "s|^LD_PRELOAD=\${LOCAL_PRELOAD}|QT_API=\${QT_API:-${qt_api}} LD_PRELOAD=\${LOCAL_PRELOAD}|" \
		"${ED}${MY_PREFIX}/bin/launch_mantidworkbench.standalone" || die

	# Keep PYTHONPATH wrapper-local to avoid polluting unrelated builds.
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
