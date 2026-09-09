# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Add datavis for sasview's unconditional PySide6.QtDataVisualization import;
# it pairs with this overlay's qtdatavis3d.

# Bundle the PyPI components so PySide and shiboken share one toolchain.

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
LLVM_COMPAT=( {18..22} )
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1

inherit distutils-r1 llvm-r2 multiprocessing ninja-utils qt-utils virtualx

MY_PN=${PN}-setup-everywhere-src
MY_P=${MY_PN}-${PV}

DESCRIPTION="Python bindings for the Qt framework"
HOMEPAGE="https://wiki.qt.io/PySide6"

if [[ ${PV} == *.9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI=(
		"https://code.qt.io/${PN}/${PN}-setup.git"
		"https://github.com/qtproject/${PN}-${PN}-setup.git"
	)
	EGIT_BRANCH=dev
	[[ ${PV} == 6.*.9999 ]] && EGIT_BRANCH=${PV%.9999}
else
	SRC_URI="https://download.qt.io/official_releases/QtForPython/${PN}6/PySide6-${PV}-src/${MY_P}.tar.xz"
	S="${WORKDIR}/${MY_P}"
	# Limited to arches supported by qtdatavis3d and qtgraphs; broader keywords
	# create unsolvable dependency trees. verified 2026-05-18
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="|| ( GPL-2 GPL-3 LGPL-3 )"
SLOT="6/${PV}"

# Keep modules in dependency order; widget variants are added below.
declare -A QT_MODULES=(
	["3d"]="3DCore 3DRender 3DLogic 3DInput 3DAnimation 3DExtras"
	["bluetooth"]="Bluetooth"
	["charts"]="Charts"
	["+concurrent"]="Concurrent"
	["+core"]="Core"
	["datavis"]="DataVisualization"
	["+dbus"]="DBus"
	["designer"]="Designer"
	["graphs"]="Graphs" # plus widgets
	["+gui"]="Gui"
	["help"]="Help"
	["httpserver"]="HttpServer"
	["location"]="Location"
	["multimedia"]="Multimedia" # plus widgets
	["network-auth"]="NetworkAuth"
	["+network"]="Network"
	["nfc"]="Nfc"
	["+opengl"]="OpenGL" # plus widgets
	["pdfium"]="Pdf" # plus widgets
	["positioning"]="Positioning"
	["+printsupport"]="PrintSupport"
	["qml"]="Qml"
	["quick3d"]="Quick3D"
	["quick"]="Quick" # plus widgets
	["remoteobjects"]="RemoteObjects"
	["scxml"]="Scxml"
	["sensors"]="Sensors"
	["serialbus"]="SerialBus"
	["serialport"]="SerialPort"
	["spatialaudio"]="SpatialAudio"
	["+sql"]="Sql"
	["svg"]="Svg" # plus widgets
	["speech"]="TextToSpeech"
	["+testlib"]="Test"
	["uitools"]="UiTools"
	["webchannel"]="WebChannel"
	["webengine"]="WebEngineCore" # plus widgets and quick
	["websockets"]="WebSockets"
	["webview"]="WebView"
	["+widgets"]="Widgets"
	["+xml"]="Xml"
)

# Re-extract on bumps from ${S}:
#     $ grep -E '(set|list).*_deps' sources/pyside6/PySide6/Qt*/CMakeLists.txt
declare -A QT_REQUIREMENTS=(
	["3d"]="gui network"
	["bluetooth"]="core"
	["charts"]="core gui widgets"
	["concurrent"]="core"
	["datavis"]="gui opengl qml"
	["dbus"]="core"
	["designer"]="widgets"
	["gles2-only"]="gui"
	["graphs"]="core network gui qml quick quick3d"
	["gui"]="core"
	["help"]="widgets"
	["httpserver"]="core concurrent network websockets"
	["location"]="core positioning"
	["multimedia"]="core gui network"
	["network-auth"]="network"
	["network"]="core"
	["nfc"]="core"
	["opengl"]="gui"
	["pdfium"]="core gui network"
	["positioning"]="core"
	["printsupport"]="widgets"
	["qml"]="network"
	["quick"]="gui network qml"
	["quick3d"]="gui network qml quick"
	["remoteobjects"]="core network"
	["scxml"]="core"
	["sensors"]="core"
	["serialbus"]="core network serialport"
	["serialport"]="core"
	["spatialaudio"]="core gui network multimedia"
	["speech"]="core multimedia"
	["sql"]="widgets"
	["svg"]="gui"
	["testlib"]="widgets"
	["uitools"]="widgets"
	["webchannel"]="core"
	["webengine"]="core gui network printsupport webchannel"
	["websockets"]="network"
	["webview"]="gui quick webengine"
	["widgets"]="gui"
	["xml"]="core"
)
# Re-extract on bumps from ${S}:
#     $ grep 'check_qt_opengl' sources/pyside6/PySide6/Qt*/CMakeLists.txt
declare -a CONDITIONAL_OPENGL=(
	3d graphs quick
)

IUSE="${!QT_MODULES[*]} debug doc gles2-only numpy test tools"
RESTRICT="!test? ( test )"

# Most QtQml tests require QtQuick.
REQUIRED_USE="
	test? (
		qml? ( quick )
	)
"
for requirement in "${!QT_REQUIREMENTS[@]}"; do
	REQUIRED_USE+=" ${requirement}? ( ${QT_REQUIREMENTS[${requirement}]} ) "
done

QT_PV="$(ver_cut 1-3)*:6"

# tools remains automagic based on installed Qt utilities.

# WebEngine requires either ALSA or PulseAudio.
RDEPEND="
	dev-libs/libxml2:=
	dev-libs/libxslt
	=dev-qt/qtbase-${QT_PV}[concurrent?,dbus?,gles2-only=,network?,opengl=,sql?,widgets?,xml?]
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
	')
	3d? ( =dev-qt/qt3d-${QT_PV}[qml?,gles2-only=] )
	bluetooth? ( =dev-qt/qtconnectivity-${QT_PV}[bluetooth] )
	charts? ( =dev-qt/qtcharts-${QT_PV} )
	datavis? ( =dev-qt/qtdatavis3d-${QT_PV} )
	designer? ( =dev-qt/qttools-${QT_PV}[designer,widgets,gles2-only=] )
	graphs? ( =dev-qt/qtgraphs-${QT_PV}[quick3d] )
	gui? (
		=dev-qt/qtbase-${QT_PV}[gui,jpeg(+)]
		x11-libs/libxkbcommon
	)
	help? ( =dev-qt/qttools-${QT_PV}[assistant,gles2-only=] )
	httpserver? ( =dev-qt/qthttpserver-${QT_PV} )
	location? ( =dev-qt/qtlocation-${QT_PV} )
	multimedia? ( =dev-qt/qtmultimedia-${QT_PV}[widgets(+)?] )
	network? ( =dev-qt/qtbase-${QT_PV}[ssl] )
	network-auth? ( =dev-qt/qtnetworkauth-${QT_PV} )
	nfc? ( =dev-qt/qtconnectivity-${QT_PV}[nfc] )
	numpy? ( >=dev-python/numpy-2.1.3[${PYTHON_USEDEP}] )
	pdfium? ( =dev-qt/qtwebengine-${QT_PV}[pdfium(-),widgets?] )
	positioning? ( =dev-qt/qtpositioning-${QT_PV} )
	printsupport? ( =dev-qt/qtbase-${QT_PV}[gui,widgets] )
	qml? ( =dev-qt/qtdeclarative-${QT_PV}[opengl?,widgets?] )
	quick3d? ( =dev-qt/qtquick3d-${QT_PV}[opengl?] )
	remoteobjects? ( =dev-qt/qtremoteobjects-${QT_PV} )
	scxml? ( =dev-qt/qtscxml-${QT_PV} )
	sensors? ( =dev-qt/qtsensors-${QT_PV}[qml?] )
	speech? ( =dev-qt/qtspeech-${QT_PV} )
	serialbus? ( =dev-qt/qtserialbus-${QT_PV} )
	serialport? ( =dev-qt/qtserialport-${QT_PV} )
	svg? ( =dev-qt/qtsvg-${QT_PV} )
	testlib? ( =dev-qt/qtbase-${QT_PV}[gui] )
	tools? (
		=dev-qt/qtbase-${QT_PV}
		=dev-qt/qtdeclarative-${QT_PV}[qmlls]
		=dev-qt/qttools-${QT_PV}[assistant,designer,linguist]
		dev-python/pkginfo[${PYTHON_USEDEP}]
	)
	uitools? ( =dev-qt/qttools-${QT_PV}[gles2-only=,widgets] )
	webchannel? ( =dev-qt/qtwebchannel-${QT_PV} )
	webengine? ( || (
		=dev-qt/qtwebengine-${QT_PV}[alsa,widgets?]
		=dev-qt/qtwebengine-${QT_PV}[pulseaudio,widgets?]
		)
	)
	websockets? ( =dev-qt/qtwebsockets-${QT_PV} )
	webview? ( =dev-qt/qtwebview-${QT_PV} )
	!dev-python/pyside:0
"

DEPEND="${RDEPEND}
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
		llvm-core/llvm:${LLVM_SLOT}
	')
	dev-util/vulkan-headers
	test? ( =dev-qt/qtbase-${QT_PV}[gui] )
" # qtbase's gui flag controls testlib

BDEPEND="
	dev-build/cmake
	dev-python/distro[${PYTHON_USEDEP}]
	dev-python/wheel[${PYTHON_USEDEP}]
	dev-util/patchelf
	doc? (
		>=dev-libs/libxml2-2.6.32
		>=dev-libs/libxslt-1.1.19
		media-gfx/graphviz
		dev-python/sphinx[${PYTHON_USEDEP}]
		dev-python/myst-parser[${PYTHON_USEDEP}]
	)
	numpy? ( dev-python/numpy[${PYTHON_USEDEP}] )
	test? ( dev-python/pkginfo[${PYTHON_USEDEP}] )
"

PATCHES=(
	"${FILESDIR}/${PN}-6.10.0-dont-vendor-ffmpeg.patch"
	"${FILESDIR}/${PN}-6.10.1-pass-ninja-opts.patch"
	"${FILESDIR}/${PN}-6.11.0-find-cmake-helpers.patch"
	"${FILESDIR}/${PN}-6.11.1-fix-llvm-version.patch"
)

# Upstream duplicates system libraries.
QA_PREBUILT=(
	"/usr/lib/python*/site-packages/PySide6/*"
)

python_prepare_all() {
	distutils-r1_python_prepare_all

	# Add Gentoo's Vulkan include path instead of requiring an SDK environment.
	sed -i -e "s~\bdetectVulkan(&headerPaths);~headerPaths.append(HeaderPath{QByteArrayLiteral(\"${EPREFIX}/usr/include/vulkan\"), HeaderType::System});~" \
			sources/shiboken6_generator/ApiExtractor/clangparser/compilersupport.cpp || die

	# Pin builtin headers to LLVM_SLOT: choosing the highest leftover Clang dir
	# breaks downgrades, while toolchain-funcs depends on the user's compiler.
	# raiagent#85; Gentoo bug #619490
	sed -e \
		's~(findClangBuiltInIncludesDir())~(QStringLiteral("'"${EPREFIX}"'/usr/lib/clang/'"${LLVM_SLOT}"'/include"))~' \
		-i sources/shiboken6_generator/ApiExtractor/clangparser/compilersupport.cpp || die

	sed -e \
		's~set(libclang_directory_suffix "lib")~set(libclang_directory_suffix "'"$(get_libdir)"'")~' \
		-i sources/shiboken6/cmake/ShibokenHelpers.cmake || die

	# blacklist.txt acts as XFAIL.
	cat <<- EOF >> build_history/blacklist.txt || die
	# Segfaults in QOpenGLContext::create.
	[pysidetest::qapp_like_a_macro_test]
		linux
	# mypy is unavailable.
	[pysidetest::mypy_correctness_test]
		linux
	# Tries to run pip install.
	[pyside6-deploy::test_pyside6_deploy]
		linux
	[pyside6-android-deploy::test_pyside6_android_deploy]
		linux
	# Stale expectation after PYSIDE-3135.
	[registry::existence_test]
		linux
	# Tries Wayland under virtualx.
	[QtUiTools::loadUiType_test]
		linux
	# Suspected Python 3.14 failure.
	[sample::multiple_derived]
		linux
	# Tries Wayland under virtualx.
	[QtWidgets::qapp_issue_585]
		linux
	EOF

	if ! use numpy; then
		cat <<- EOF >> build_history/blacklist.txt || die
		# Require numpy support.
		[sample::array_numpy]
			linux
		[sample::nontypetemplate]
			linux
		[QtGui::qpainter_test]
			linux
		[QtCore::qrangemodel_test]
			linux
		[QtGraphs::qgraphs_numpy_test]
			linux
		EOF
	fi
}

python_configure_all() {
	export LLVM_INSTALL_DIR="$(get_llvm_prefix)"

	# Forward package-manager parallelism through the patched build.
	export NINJAOPTS="$(get_NINJAOPTS)"

	ENABLED_QT_MODULES=()

	# Recursively add dependencies before their consumers.
	enable_qt_mod() {
		local flag=${1}
		local modules=${QT_MODULES[${flag}]}
		if [[ -z ${modules} ]]; then
			die "incorrect flag=${flag}, not registered"
		fi
		local dependencies=${QT_REQUIREMENTS[${flag//+}]}
		if [[ -n ${dependencies} ]]; then
			local depflag
			for depflag in ${dependencies}; do
				if use "${depflag}"; then
					if [[ -z ${QT_MODULES[${depflag}]} ]]; then
						depflag=+${depflag}
					fi
					enable_qt_mod "${depflag}"
				else
					die "${depflag} is required but not enabled"
				fi
			done
			if use opengl && [[ ${CONDITIONAL_OPENGL[@]} =~ ${flag//+} ]]; then
				enable_qt_mod "+opengl"
			fi
		fi
		if [[ "${ENABLED_QT_MODULES[*]}" != *${modules}* ]]; then
			ENABLED_QT_MODULES+=( ${modules} )
		fi
	}
	local flag
	for flag in "${!QT_MODULES[@]}"; do
		if use "${flag//+}"; then
			enable_qt_mod "${flag}"
		fi
	done

	# Add widget, quick, and test variants not represented in QT_MODULES.
	if use widgets; then
		use multimedia && ENABLED_QT_MODULES+=( MultimediaWidgets )
		use opengl && ENABLED_QT_MODULES+=( OpenGLWidgets )
		use pdfium && ENABLED_QT_MODULES+=( PdfWidgets )
		use quick && ENABLED_QT_MODULES+=( QuickWidgets )
		use graphs && ENABLED_QT_MODULES+=( GraphsWidgets ) # requires QuickWidgets
		use svg && ENABLED_QT_MODULES+=( SvgWidgets )
		use webengine && ENABLED_QT_MODULES+=( WebEngineWidgets )
	fi
	if use quick; then
		use webengine && ENABLED_QT_MODULES+=( WebEngineQuick )
		use testlib && ENABLED_QT_MODULES+=( QuickTest )
	fi

	MAIN_DISTUTILS_ARGS=(
		--cmake="${ESYSROOT}/usr/bin/cmake"
		--ignore-git
		--limited-api=no
		--module-subset="$(printf '%s,' "${ENABLED_QT_MODULES[@]}")"
		--no-strip
		--no-size-optimization
		--openssl="${ESYSROOT}/usr/bin/openssl"
		--qt="$(ver_cut 1-3)"
		--qtpaths="$(qt_get_broot_binary 6 qtpaths)"
		--log-level=verbose
		--parallel="$(makeopts_jobs)"
		"$(usex debug "--debug" "--relwithdebinfo")"
		"--$(usex doc "build" "skip")-docs"
		"--$(usex numpy "enable" "disable")-numpy-support"
	)

	if use test; then
		MAIN_DISTUTILS_ARGS+=(
			"--build-tests"
			"--use-xvfb"
		)
	fi

	if ! use tools; then
		MAIN_DISTUTILS_ARGS+=(
			"--no-qt-tools"
		)
	fi
}

python_compile() {
	DISTUTILS_ARGS=(
		"${MAIN_DISTUTILS_ARGS[@]}"
		--build-type=shiboken6-generator
	)
	distutils-r1_python_compile

	# Discover upstream's dynamically named build directory.
	local pyside_build_dir
	read -r pyside_build_dir < <(
		find "${BUILD_DIR}/build$((${#DISTUTILS_WHEELS[@]}-1))" \
			-maxdepth 1 -type d -name 'qfp*-py*-qt*-*' -printf "%f\n"
	)
	export pyside_build_id="${pyside_build_dir#"qfp$(usev debug d)-py${EPYTHON#python}-qt$(ver_cut 1-3)-"}"
	export PYTHONPATH="${BUILD_DIR}/build$((${#DISTUTILS_WHEELS[@]}-1))/${pyside_build_dir}/package:${BUILD_DIR}/build$((${#DISTUTILS_WHEELS[@]}-1))/${pyside_build_dir}/install/lib/${EPYTHON}/site-packages:${PYTHONPATH}"

	DISTUTILS_ARGS=(
		"${MAIN_DISTUTILS_ARGS[@]}"
		--reuse-build
		--shiboken-target-path="${BUILD_DIR}/build$((${#DISTUTILS_WHEELS[@]}-1))/${pyside_build_dir}/package/shiboken6_generator"
		--build-type=shiboken6
	)
	distutils-r1_python_compile
	export PYTHONPATH="${BUILD_DIR}/build$((${#DISTUTILS_WHEELS[@]}-1))/${pyside_build_dir}/package:${BUILD_DIR}/build$((${#DISTUTILS_WHEELS[@]}-1))/${pyside_build_dir}/install/lib/${EPYTHON}/site-packages:${PYTHONPATH}"

	# Merge the generator payload so the next stage can reuse shiboken-target-path.
	rsync -ur \
		"${BUILD_DIR}/build$((${#DISTUTILS_WHEELS[@]}-2))/${pyside_build_dir}/package/shiboken6_generator/"* \
		"${BUILD_DIR}/build$((${#DISTUTILS_WHEELS[@]}-1))/${pyside_build_dir}/package/shiboken6/" \
		|| die
	ln -s shiboken6 \
		"${BUILD_DIR}/build$((${#DISTUTILS_WHEELS[@]}-1))/${pyside_build_dir}/package/shiboken6_generator" \
		|| die

	# With no PySide modules, ship only shiboken.
	if [[ ${#ENABLED_QT_MODULES[@]} -gt 0 ]]; then
		DISTUTILS_ARGS=(
			"${MAIN_DISTUTILS_ARGS[@]}"
			--reuse-build
			--shiboken-target-path="${BUILD_DIR}/build$((${#DISTUTILS_WHEELS[@]}-1))/${pyside_build_dir}/package/shiboken6"
			--build-type=pyside6
		)
		distutils-r1_python_compile
		export PYTHONPATH="${BUILD_DIR}/build$((${#DISTUTILS_WHEELS[@]}-1))/${pyside_build_dir}/package:${BUILD_DIR}/build$((${#DISTUTILS_WHEELS[@]}-1))/${pyside_build_dir}/install/lib/${EPYTHON}/site-packages:${PYTHONPATH}"
	fi

	# Provide conventional library paths for compatibility.
	pushd "${BUILD_DIR}/install/$(python_get_sitedir)" >/dev/null ||
		die
	mkdir -p "${BUILD_DIR}/install/usr/$(get_libdir)" || die
	local lib
	for lib in */*.cpython-*.so
	do
		local base=${lib##*/}
		ln -s "${base}" "${lib%/*}/${base%%.*}-${EPYTHON}.so" ||
			die
	done
	for lib in */*.cpython-*.so."$(ver_cut 1-2)"
	do
		local base=${lib##*/}
		ln -s "${base}" "${lib%/*}/${base%%.*}-${EPYTHON}.so.$(ver_cut 1-2)" ||
			die
	done
	for lib in */*.so*; do
		ln -s "../../$(python_get_sitedir)/${lib}" \
			"${BUILD_DIR}/install/usr/$(get_libdir)/${lib#*/}" || die
	done
	popd >/dev/null || die

	# Mirror paths expected by PyPI-wheel consumers.
	local dir
	if [[ -d ${BUILD_DIR}/install/$(python_get_sitedir)/PySide6 ]]
	then
		pushd "${BUILD_DIR}/install/$(python_get_sitedir)/PySide6" \
			>/dev/null || die
		mkdir -p "${BUILD_DIR}/install/usr/share/PySide6" || die
		for dir in doc glue typesystems; do
			ln -s "../../../$(python_get_sitedir)/PySide6/${dir}" \
				"${BUILD_DIR}/install/usr/share/PySide6/${dir}" ||
					die
		done
		popd >/dev/null || die
	fi
	mkdir -p "${BUILD_DIR}/install/usr/include"
	for dir in PySide6 shiboken6 shiboken6_generator; do
		if [[ -d ${BUILD_DIR}/install/$(python_get_sitedir)/${dir}/include ]]
		then
			ln -s "../../$(python_get_sitedir)/${dir}/include" \
				"${BUILD_DIR}/install/usr/include/${dir//_generator}" ||
					die
		fi
	done

	# Collect metadata and the Designer plugin from inner install trees.
	find "${BUILD_DIR}"/build*/"${pyside_build_dir}"/install -type f \
		-name libPySidePlugin.so -exec \
		mkdir -p "${BUILD_DIR}/install/$(qt_get_plugindir 6)/designer/" \; \
		-exec \
		cp "{}" "${BUILD_DIR}/install/$(qt_get_plugindir 6)/designer/" \; \
			|| die

	for dir in cmake pkgconfig; do
		find "${BUILD_DIR}"/build*/"${pyside_build_dir}"/install -type d -name "${dir}" \
			-exec cp -r "{}" "${BUILD_DIR}/install/usr/lib/" \; \
				|| die
	done

	# Create per-Python pkg-config files; the last target owns the unversioned one.
	if [[ -f ${BUILD_DIR}/install/usr/lib/pkgconfig/shiboken6.pc ]]
	then
		sed -e 's~prefix=.*~prefix=/usr~g' \
			-e 's~exec_prefix=.*~exec_prefix=${prefix}~g' \
			-e "s~libdir=.*~libdir=$(python_get_sitedir)/shiboken6~g" \
			-e "s~includedir=.*~includedir=$(python_get_sitedir)/shiboken6_generator/include~g" \
			-i "${BUILD_DIR}/install/usr/lib/pkgconfig/shiboken6.pc" || die
		cp "${BUILD_DIR}/install/usr/lib/pkgconfig/"shiboken6{,-${EPYTHON}}.pc || die
	fi
	if [[ -f ${BUILD_DIR}/install/usr/lib/pkgconfig/pyside6.pc ]]
	then
		sed -e 's~^Requires: shiboken6$~&-'${EPYTHON}'~' \
			-e 's~prefix=.*~prefix=/usr~g' \
			-e 's~exec_prefix=.*~exec_prefix=${prefix}~g' \
			-e "s~libdir=.*~libdir=$(python_get_sitedir)/PySide6~g" \
			-e "s~includedir=.*~includedir=$(python_get_sitedir)/PySide6/include~g" \
			-e "s~typesystemdir=.*~typesystemdir=$(python_get_sitedir)/PySide6/typesystems~g" \
			-e "s~gluedir=.*~gluedir=$(python_get_sitedir)/PySide6/glue~g" \
			-e "s~pythonpath=.*~pythonpath=$(python_get_sitedir)~g" \
			-i "${BUILD_DIR}/install/usr/lib/pkgconfig/pyside6.pc" || die
		cp "${BUILD_DIR}/install/usr/lib/pkgconfig/"pyside6{,-${EPYTHON}}.pc || die
	fi

	# Replace fragile _IMPORT_PREFIX paths; generated files vary across systems.
	sed \
		-e "s~\${_IMPORT_PREFIX}/lib/libshiboken6\.cpython~/usr/$(get_libdir)/libshiboken6\.cpython~g" \
		-e "s~\${_IMPORT_PREFIX}/shiboken6/libshiboken6\.cpython~/usr/$(get_libdir)/libshiboken6\.cpython~g" \
		-e "s~\${_IMPORT_PREFIX}/bin/shiboken6~/usr/bin/shiboken6~g" \
		-e "s~\${_IMPORT_PREFIX}/shiboken6_generator/shiboken6~/usr/bin/shiboken6~g" \
		-e "s~\${_IMPORT_PREFIX}/lib/libpyside6\.cpython~/usr/$(get_libdir)/libpyside6\.cpython~g" \
		-e "s~\${_IMPORT_PREFIX}/PySide6/libpyside6\.cpython~/usr/$(get_libdir)/libpyside6\.cpython~g" \
		-e "s~\${_IMPORT_PREFIX}/lib/libpyside6qml\.cpython~/usr/$(get_libdir)/libpyside6qml\.cpython~g" \
		-e "s~\${_IMPORT_PREFIX}/PySide6/libpyside6qml\.cpython~/usr/$(get_libdir)/libpyside6qml\.cpython~g" \
		-e "s~libshiboken6\.cpython.*\.so\.$(ver_cut 1-3)~libshiboken6\${PYTHON_CONFIG_SUFFIX}\.so\.$(ver_cut 1-2)~g" \
		-e "s~libpyside6\.cpython.*\.so\.$(ver_cut 1-3)~libpyside6\${PYTHON_CONFIG_SUFFIX}\.so\.$(ver_cut 1-2)~g" \
		-e "s~libpyside6qml\.cpython.*\.so\.$(ver_cut 1-3)~libpyside6qml\${PYTHON_CONFIG_SUFFIX}\.so\.$(ver_cut 1-2)~g" \
		-e "s~libshiboken6\.cpython.*\.so\.$(ver_cut 1-2)~libshiboken6\${PYTHON_CONFIG_SUFFIX}\.so\.$(ver_cut 1-2)~g" \
		-e "s~libpyside6\.cpython.*\.so\.$(ver_cut 1-2)~libpyside6\${PYTHON_CONFIG_SUFFIX}\.so\.$(ver_cut 1-2)~g" \
		-e "s~libpyside6qml\.cpython.*\.so\.$(ver_cut 1-2)~libpyside6qml\${PYTHON_CONFIG_SUFFIX}\.so\.$(ver_cut 1-2)~g" \
		-e "s~\${PACKAGE_PREFIX_DIR}/~\${PACKAGE_PREFIX_DIR}/share/PySide6/~g" \
		-e "s~\${_IMPORT_PREFIX}/shiboken6/include~/usr/include/shiboken6~g" \
		-e "s~\${_IMPORT_PREFIX}/PySide6/include~/usr/include/PySide6~g" \
		-i "${BUILD_DIR}/install/usr/lib/cmake/"*/*.cmake || die
	local file
	for file in "${BUILD_DIR}/install/usr/lib/cmake/"*/*.cpython-*.cmake
	do
		local base=${file##*/}
		ln -s "${base}" "${file%/*}/${base%%.*}-${EPYTHON}.cmake" ||
			die
	done
}

python_test() {
	# Select this interpreter's build instead of the last multi-target build.
	local pyside_build_dir="qfp$(usev debug d)-py${EPYTHON#python}-qt$(ver_cut 1-3)-${pyside_build_id}"

	local buildno=$(find "${BUILD_DIR}"/build* -name "${pyside_build_dir}" | sort -V | tail -n1)
	if [[ -z "${buildno}" ]]; then
		die "could not find any build directories for ${pyside_build_dir}"
	fi

	buildno="${buildno#"${BUILD_DIR}/build"}"
	buildno="${buildno%"/${pyside_build_dir}"}"

	local -x PYTHONPATH="${BUILD_DIR}/install$(python_get_sitedir)"
	local -x QTEST_ENVIRONMENT=ci

	virtx ${EPYTHON} testrunner.py test --buildno "$((buildno - 1))" --projects=shiboken6 ||
		die "Tests failed with ${EPYTHON}"

	if use core; then
		virtx ${EPYTHON} testrunner.py test --buildno "${buildno}" --projects=pyside6 ||
			die "Tests failed with ${EPYTHON}"
	fi
}

pkg_preinst() {
	# Avoid directories blocking replacement symlinks.
	rm -rf "${EROOT}/usr/include/"{PySide6,shiboken6} || die
	rm -rf "${EROOT}/usr/share/PySide6" || die
}
