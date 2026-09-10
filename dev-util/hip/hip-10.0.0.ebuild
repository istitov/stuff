# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOCS_BUILDER="doxygen"
DOCS_DEPEND="media-gfx/graphviz"
ROCM_SKIP_GLOBALS=1

# The subslot-pinned ROCm stack must use one LLVM major.
LLVM_COMPAT=( 23 )

inherit cmake docs flag-o-matic llvm-r2 rocm

DESCRIPTION="C++ Heterogeneous-Compute Interface for Portability"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/clr"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_SUBMODULES=()
	EGIT_REPO_URI="https://github.com/ROCm/rocm-systems.git"
	S="${WORKDIR}/${P}/projects/clr"
	HIP_S="${WORKDIR}/${P}/projects/hip"
	SLOT="0/10.0"
else
	# ROCm assets now use therock-<major.minor>; clr.tar.gz is shared with
	# rocm-opencl-runtime.
	MY_BASE="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)"
	SRC_URI="
		${MY_BASE}/clr.tar.gz -> rocm-clr-${PV}.tar.gz
		${MY_BASE}/${PN}.tar.gz -> ${P}.tar.gz
	"
	S="${WORKDIR}/clr/"
	HIP_S="${WORKDIR}/hip"
	KEYWORDS="~amd64"
	SLOT="0/$(ver_cut 1-2)"
fi

LICENSE="MIT"

IUSE="debug +hip numa opencl video_cards_amdgpu video_cards_nvidia"

# The broken suite tests an installed runtime, not the build tree.
RESTRICT="test"

REQUIRED_USE="
	|| ( hip opencl )
	^^ ( video_cards_amdgpu video_cards_nvidia )
"

DEPEND="
	video_cards_amdgpu? (
		dev-util/rocminfo:${SLOT}
		dev-libs/rocm-comgr:${SLOT}
		dev-libs/rocr-runtime:${SLOT}
	)
	video_cards_nvidia? ( dev-libs/hipother:${SLOT} )
	x11-base/xorg-proto
	virtual/opengl[X]
	numa? ( sys-process/numactl )
"
BDEPEND="
	video_cards_amdgpu? (
		dev-util/hipcc:${SLOT}
	)
"
RDEPEND="${DEPEND}
	~dev-libs/rocm-core-${PV}
	opencl? (
		!dev-libs/opencl-icd-loader
		!dev-libs/rocm-opencl-runtime
		!dev-util/clinfo
		!dev-util/opencl-headers
	)
	video_cards_amdgpu? (
		dev-util/hipcc:${SLOT}
		dev-libs/rocm-device-libs:${SLOT}
		dev-libs/roct-thunk-interface:${SLOT}
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-6.3.0-no-isystem-usr-include.patch"
	# GCC 16's libstdc++ also needs the former libc++-only noinline fix.
	"${FILESDIR}/${PN}-10.0.0-fix-stdlib-noinline.patch"
	"${FILESDIR}/${PN}-7.1.0-no-hipother-install.patch"
	# Without this, hipStreamCreate() segfaults outright on an AVX-512 host.
	"${FILESDIR}/${PN}-10.0.0-aligned-new.patch"
)

QA_FLAGS_IGNORED="usr/lib.*/libhiprtc-builtins.*"

src_unpack() {
	# Release assets provide the top-level directories expected by S and HIP_S.
	unpack "rocm-clr-${PV}.tar.gz"
	unpack "${P}.tar.gz"
}

src_prepare() {
	pushd "${HIP_S}" >/dev/null || die

	# Some consumers still use FindHIP.cmake. Replace its comment anchors with
	# Gentoo paths and require both matches before sed can silently miss them.
	# verified 2026-08-29
	grep -q '# Search for HIP installation' cmake/FindHIP.cmake ||
		die "FindHIP.cmake 'Search for HIP installation' comment anchor moved"
	grep -q '#Set HIP_CLANG_PATH' cmake/FindHIP.cmake ||
		die "FindHIP.cmake 'Set HIP_CLANG_PATH' comment anchor moved"
	sed -e "s:# Search for HIP installation:set(HIP_ROOT_DIR \"${EPREFIX}/usr\"):" \
		-e "s:#Set HIP_CLANG_PATH:set(HIP_CLANG_PATH \"$(get_llvm_prefix -d)/bin\"):" \
		-i "cmake/FindHIP.cmake" || die
	popd >/dev/null || die

	# Disable upstream -Werror; require the anchor so it cannot return silently.
	grep -qF ' -Werror' "hipamd/src/CMakeLists.txt" ||
		die "-Werror anchor moved in hipamd/src/CMakeLists.txt"
	sed -e "s/ -Werror//g" -i "hipamd/src/CMakeLists.txt" || die

	# Require the anchor so ASan documentation cannot silently enter the image.
	grep -qF 'asan COMPONENT asan' hipamd/packaging/CMakeLists.txt ||
		die "asan COMPONENT anchor moved; the asan doc dir would be installed"
	sed -e "/asan COMPONENT asan/d" -i hipamd/packaging/CMakeLists.txt || die

	# Do not leave the installed CMake placeholder unsubstituted.
	grep -qF '@HIP_INSTALLS_HIPCC@' hipamd/hip-config.cmake.in ||
		die "@HIP_INSTALLS_HIPCC@ anchor moved in hipamd/hip-config.cmake.in"
	sed -e "s/@HIP_INSTALLS_HIPCC@/ON/g" -i hipamd/hip-config.cmake.in || die

	# Prevent a colliding bundled hipcc; require the anchor before rewriting it.
	grep -qF 'NOT ${HIPCC_BIN_DIR}' "hipamd/CMakeLists.txt" ||
		die "HIPCC_BIN_DIR anchor moved; hip would install a colliding hipcc"
	sed -e "s/NOT \${HIPCC_BIN_DIR}/INSTALL_HIPCC AND NOT \${HIPCC_BIN_DIR}/" \
		-i "hipamd/CMakeLists.txt" || die

	# Only the vendored Khronos files retain the old CMake floor.
	# verified 2026-08-29
	local f
	for f in opencl/khronos/icd/CMakeLists.txt \
		opencl/khronos/headers/opencl2.2/tests/CMakeLists.txt; do
		grep -qE 'cmake_minimum_required.*3\.[35]' "${f}" ||
			die "cmake_minimum_required 3.[35] anchor moved in ${f}"
	done
	sed -e "/cmake_minimum_required/ s/3\.[35]/3.10/" \
		-i opencl/khronos/icd/CMakeLists.txt \
		-i opencl/khronos/headers/opencl2.2/tests/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	# Avoid strict-aliasing and LTO miscompiles. bug #858383; ROCm/clr#64
	append-flags -fno-strict-aliasing
	filter-lto

	use debug && CMAKE_BUILD_TYPE="Debug"

	# Accept versioned symbols with lld. ROCm/HIP#3382; gentoo/gentoo#29097
	append-ldflags $(test-flags-CCLD -Wl,--undefined-version)

	local mycmakeargs=(
		-DCMAKE_PREFIX_PATH="$(get_llvm_prefix)"
		-DCMAKE_SKIP_RPATH=ON
		-D__HIP_ENABLE_PCH=OFF

		-DCLR_BUILD_HIP="$(usex hip)"
		-DCLR_BUILD_OCL="$(usex opencl)"

		-DHIP_COMMON_DIR="${HIP_S}"
		-DHIP_ENABLE_ROCPROFILER_REGISTER=OFF
		-DHIPCC_BIN_DIR="${EPREFIX}/usr/bin"
		-DROCM_PATH="${EPREFIX}/usr"

		-DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
	)

	if use video_cards_amdgpu; then
		mycmakeargs+=(
			-DHIP_PLATFORM="amd"
			-DOpenGL_GL_PREFERENCE="GLVND"
			-DUSE_PROF_API=OFF
			# Retain for restored NUMA detection; inert as of 2026-05-08.
			-DCMAKE_DISABLE_FIND_PACKAGE_NUMA="$(usex !numa)"
			-DCMAKE_REQUIRE_FIND_PACKAGE_NUMA="$(usex numa)"
		)
	elif use video_cards_nvidia; then
		mycmakeargs+=(
			-DHIPNV_DIR="${EPREFIX}/usr"
			-DHIP_PLATFORM="nvidia"
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Clang 23 hardcodes <hip-path>/lib/libamdhip64.so regardless of --hip-path
	# or --rocm-path. Provide a multilib compat link, except when lib is already
	# the native libdir. verified 2026-08-29 with clang 23.1.0
	if [[ $(get_libdir) != lib ]]; then
		dosym -r "/usr/$(get_libdir)/libamdhip64.so" /usr/lib/libamdhip64.so
	fi
}
