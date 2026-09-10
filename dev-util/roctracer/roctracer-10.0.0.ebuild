# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
ROCM_VERSION=${PV}

inherit cmake flag-o-matic prefix python-any-r1 rocm toolchain-funcs

DESCRIPTION="Callback/Activity Library for Performance tracing AMD GPU's"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/roctracer"
# rocSPARSE requires a matching roctracer subslot beyond Gentoo's 7.2.x.
# AMD retired rocm-* releases; use the matching TheRock component asset.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/${PN}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/rocr-runtime:${SLOT}
	dev-libs/rocm-comgr:${SLOT}
"
DEPEND="
	${RDEPEND}
	dev-util/hip:${SLOT}
"
BDEPEND="
	$(python_gen_any_dep "
		dev-python/cppheaderparser[\${PYTHON_USEDEP}]
		dev-python/ply[\${PYTHON_USEDEP}]
	")
"

PATCHES=(
	"${FILESDIR}/${PN}-5.7.1-with-tests.patch"
	"${FILESDIR}/${PN}-7.0.1-fix-matrixtranspose-test.patch"
)

python_check_deps() {
	python_has_version "dev-python/cppheaderparser[${PYTHON_USEDEP}]" \
		"dev-python/ply[${PYTHON_USEDEP}]"
}

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	cmake_src_prepare

	hprefixify script/*.py

	# Assert every sed anchor to catch silent upstream drift; bug-workaround
	# failures may mean the sed can be dropped. # verified 2026-08-30
	local f

	# Avoid a package-specific library subdirectory.
	for f in src/CMakeLists.txt plugin/file/CMakeLists.txt; do
		grep -qF '${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}' "${f}" ||
			die "libdir anchor moved in ${f}; libs would install to a ${PN}/ subdirectory"
	done
	sed -e "s:\${CMAKE_INSTALL_LIBDIR}/\${PROJECT_NAME}:\${CMAKE_INSTALL_LIBDIR}:g" \
		-i src/CMakeLists.txt plugin/file/CMakeLists.txt || die

	# Do not install test binaries.
	grep -qE '^ *install\(' test/CMakeLists.txt ||
		die "test install() anchor moved; test binaries would be installed"
	sed -E '/^ *install\(.+/d' -i test/CMakeLists.txt || die

	# Fails upstream (ROCtracer#109).
	grep -qF 'load_unload_reload_test' test/run.sh ||
		die "load_unload_reload_test gone from test/run.sh; check whether ROCm/roctracer#109 was fixed and drop this sed"
	sed '/load_unload_reload_test/d' -i test/run.sh || die

	# Point tests at Gentoo's HIP CMake directory.
	grep -qF '${ROCM_PATH}/lib/cmake' test/CMakeLists.txt ||
		die "ROCM_PATH/lib/cmake anchor moved; the test build would not find HIP's cmake files"
	sed -e "s,\${ROCM_PATH}/lib/cmake,/usr/$(get_libdir)/cmake,g" -i test/CMakeLists.txt || die

	# Remove upstream -Werror (bug #892732).
	grep -q -- '-Werror' CMakeLists.txt ||
		die "-Werror gone from CMakeLists.txt; upstream likely dropped it, so drop this sed"
	sed -e 's/-Werror//' -i CMakeLists.txt || die

	# libc++ has no experimental/filesystem.
	for f in plugin/file/file.cpp src/hip_stats/hip_stats.cpp \
			src/roctracer/loader.h src/tracer_tool/tracer_tool.cpp; do
		grep -qF 'experimental' "${f}" ||
			die "experimental/filesystem gone from ${f}; upstream likely moved to std::filesystem, so drop this sed"
	done
	sed -e 's|experimental/||' -e 's|experimental::||' \
		-i plugin/file/file.cpp src/hip_stats/hip_stats.cpp \
		src/roctracer/loader.h src/tracer_tool/tracer_tool.cpp || die

	# Use rocm_use_clang's compiler and remove the bare-name clang dependency.
	grep -qF 'COMMAND clang' test/CMakeLists.txt ||
		die "COMMAND clang anchor moved; the test build would use whatever clang is on PATH"
	grep -qF 'DEPENDS ${INPUT_FILE} clang' test/CMakeLists.txt ||
		die "DEPENDS clang anchor moved; the test build would still depend on a bare-name clang target"
	sed -e "s/COMMAND clang/COMMAND \${CMAKE_CXX_COMPILER}/" \
		-e "s/DEPENDS \${INPUT_FILE} clang/DEPENDS \${INPUT_FILE}/" \
		-i test/CMakeLists.txt || die

	for f in CMakeLists.txt src/CMakeLists.txt plugin/file/CMakeLists.txt; do
		grep -qF 'COMPONENT asan' "${f}" ||
			die "COMPONENT asan anchor moved in ${f}; the asan component would be installed"
	done
	sed -e "s/COMPONENT asan/COMPONENT asan EXCLUDE_FROM_ALL/" \
		-i CMakeLists.txt src/CMakeLists.txt plugin/file/CMakeLists.txt || die
}

src_configure() {
	rocm_use_clang

	if [[ $(tc-get-cxx-stdlib) == "libc++" ]] ; then
		# libc++ needs its filesystem support library.
		append-libs "-lc++fs"
	fi

	local mycmakeargs=(
		-DCMAKE_MODULE_PATH="${EPREFIX}/usr/$(get_libdir)/cmake/hip"
		-DWITH_TESTS=$(usex test)
		-DPython3_EXECUTABLE="${PYTHON}"
	)
	use test && mycmakeargs+=(
		-DHIP_ROOT_DIR="${EPREFIX}/usr"
		-DGPU_TARGETS="$(get_amdgpu_flags)"
	)

	cmake_src_configure
}

src_test() {
	check_amdgpu
	cd "${BUILD_DIR}" || die
	# Ensure dlopen uses the just-built library.
	LD_LIBRARY_PATH="${EPREFIX}/usr/$(get_libdir):${LD_LIBRARY_PATH}" bash run.sh || die
}
