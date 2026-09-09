# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1
inherit cmake edo rocm flag-o-matic

DESCRIPTION="ROCm Communication Collectives Library (RCCL)"
HOMEPAGE="https://github.com/ROCm/rccl"
# ROCm 10 folded RCCL into rocm-systems; use its component asset and root.
# verified 2026-08-29
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/rccl.tar.gz -> rccl-${PV}.tar.gz"
S="${WORKDIR}/rccl"

# SPDX scan includes compiled Apache-2.0, LLVM-exception, BSD, and MIT code.
# verified 2026-08-30
LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

# RCCL supports fewer targets than the stack, so mirror DEFAULT_GPUS manually.
# ROCm 10 adds gfx1151/gfx1250 but still omits gfx1150/gfx1152/gfx1153; a
# gfx1150-only host cannot build it. verified 2026-08-29
IUSE_TARGETS=( gfx906 gfx908 gfx90a gfx942 gfx950 gfx1030 gfx1100 gfx1101 gfx1102 gfx1151 gfx1200 gfx1201 gfx1250 )
IUSE_TARGETS=( "${IUSE_TARGETS[@]/#/amdgpu_targets_}" )
ROCM_USEDEP_OPTFLAGS=${IUSE_TARGETS[*]/%/(-)?}
ROCM_USEDEP=${ROCM_USEDEP_OPTFLAGS// /,}
ROCM_REQUIRED_USE=" || ( ${IUSE_TARGETS[*]} )"

IUSE="${IUSE_TARGETS[*]/#/+} roctracer test"

REQUIRED_USE="${ROCM_REQUIRED_USE}"

RDEPEND="
	dev-util/hip:${SLOT}
	dev-util/rocm-smi:${SLOT}
	roctracer? ( dev-util/roctracer:${SLOT} )
"
DEPEND="${RDEPEND}
	dev-libs/rocr-runtime:${SLOT}
	sys-libs/binutils-libs
	dev-libs/libfmt:=
"
BDEPEND="
	dev-build/rocm-cmake:${SLOT}
	dev-util/hipify-clang:${SLOT}
	test? ( dev-cpp/gtest )"

RESTRICT="!test? ( test )"

PATCHES=(
	"${FILESDIR}/${PN}-10.0.0-fix-missing-includes.patch"
	"${FILESDIR}/${PN}-10.0.0-fix-nvtx-disabled.patch"
)

src_prepare() {
	# CRLF source needs <iostream>; use an anchored edit instead of a patch.
	grep -qF '#include "ipc_mem_handler.h"' src/ipc_init.cu ||
		die "ipc_mem_handler include anchor moved in src/ipc_init.cu"
	sed -e '/#include "ipc_mem_handler.h"/a #include <iostream>' \
		-i src/ipc_init.cu || die

	# Remove both test install sites and guard silent sed misses. rocm_install
	# calls occupy one line and can be deleted safely.
	grep -qF 'rocm_install' test/CMakeLists.txt ||
		die "rocm_install anchor moved in test/CMakeLists.txt; test binaries would be installed"
	sed -e '/rocm_install/d' -i test/CMakeLists.txt || die

	# The multiline CTestTestfile install needs component exclusion instead.
	# verified 2026-08-30
	grep -qE '^[[:space:]]*COMPONENT tests$' test/CMakeLists.txt ||
		die "CTestTestfile install anchor moved; it would be installed"
	sed -E -e 's/^([[:space:]]*)COMPONENT tests$/\1COMPONENT tests EXCLUDE_FROM_ALL/' \
		-i test/CMakeLists.txt || die

	# Remove FORCE so Gentoo's multilib path wins; guard the silent sed miss.
	grep -qF 'CMAKE_INSTALL_LIBDIR' cmake/Dependencies.cmake ||
		die "CMAKE_INSTALL_LIBDIR anchor moved in cmake/Dependencies.cmake"
	sed -e '/CMAKE_INSTALL_LIBDIR/ s/ FORCE//' -i cmake/Dependencies.cmake || die
	cmake_src_prepare
}

src_configure() {
	rocm_use_clang

	# LTO fails with undefined hidden symbols.
	filter-lto

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		# Upstream's supported warning-suppression switch.
		-DQUIET_WARNINGS=ON
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		-DBUILD_TESTS=$(usex test ON OFF)
		-DROCM_SYMLINK_LIBS=OFF
		-DROCM_PATH="${EPREFIX}/usr"
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DRCCL_ROCPROFILER_REGISTER=OFF
		-DENABLE_MSCCLPP=OFF
		-DROCTX=$(usex roctracer ON OFF)
		-DEXPLICIT_ROCM_VERSION="${PV}"
		-Wno-dev
	)

	cmake_src_configure
}

src_test() {
	check_amdgpu
	cd "${BUILD_DIR}" || die
	# Hide a secondary APU that breaks the tests.
	HIP_VISIBLE_DEVICES=0 LD_LIBRARY_PATH="${BUILD_DIR}" edob test/rccl-UnitTests
}
