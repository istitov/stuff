# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1
inherit cmake edo rocm flag-o-matic

DESCRIPTION="ROCm Communication Collectives Library (RCCL)"
HOMEPAGE="https://github.com/ROCm/rccl"
# ROCm/rccl was FOLDED INTO the rocm-systems monorepo for 10.0: the standalone
# repo's newest own tag is therock-7.11, and the 10.0 sources ship only as the
# rccl.tar.gz release asset. Source-shape change, not just a tag swap -- the
# git-archive form is gone and S= follows the asset's own root.
# verified 2026-08-29.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/rccl.tar.gz -> rccl-${PV}.tar.gz"
S="${WORKDIR}/rccl"

# SPDX tags across the 10.0 source: 383 Apache-2.0 (303 of them under src/, so
# this is compiled code and not just tooling), 43 BSD-3-Clause, 33 Apache-2.0
# WITH LLVM-exception, 21 MIT, plus a handful marked "Apache-2.0 and BSD-3".
# The previous LICENSE="BSD" was materially incomplete. verified 2026-08-30.
# NB dev-libs/rccl-7.2.4 carries the same understated field.
LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

# Mirrors upstream's DEFAULT_GPUS list in CMakeLists.txt -- rccl supports a
# NARROWER set of architectures than the rest of the ROCm stack, so this is
# hand-maintained rather than taken from rocm.eclass.
#
# Re-read from the therock-10.0 asset 2026-08-29: 10.0 ADDS gfx1151 and
# gfx1250 (the 7.2.4 comment here said gfx1151 was unsupported; that is no
# longer true). gfx1150 is STILL absent -- so despite ROCm 10.0 making gfx1150
# officially supported stack-wide, rccl cannot be built for it, and this
# package remains unbuildable on a gfx1150-only host. gfx1152/gfx1153 are
# likewise absent upstream.
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

# ${PN}-7.0.1-fix-libcxx.patch is NOT carried: it wrapped an
# #include <bits/c++config.h> / _GLIBCXX_VISIBILITY override in src/ras/ras.cc
# in #ifdef __GLIBCXX__ so libc++ builds would not pull a libstdc++-only
# header. ROCm 10.0 removed that include from ras.cc entirely, so there is
# nothing left to guard and the hunks no longer apply.
# verified 2026-08-29 against the therock-10.0 rccl asset.
PATCHES=()

src_prepare() {
	# Don't install tests. There are TWO install sites in this file, both
	# reachable only under USE=test (src_configure passes -DBUILD_TESTS), and
	# both silent on no-match -- sed exits 0 either way, so a stale anchor
	# merges test content instead of failing the build.
	#
	# 1. the per-executable rocm_install(). One complete call per line, so
	#    deleting the line cannot orphan a block.
	grep -qF 'rocm_install' test/CMakeLists.txt ||
		die "rocm_install anchor moved in test/CMakeLists.txt; test binaries would be installed"
	sed -e '/rocm_install/d' -i test/CMakeLists.txt || die

	# 2. a plain install() for CTestTestfile.cmake. It carries no rocm_install
	#    token, so the delete above never saw it and it still landed in
	#    /usr/bin/rccl/. Mark the component excluded rather than delete: the
	#    call spans six lines, which is not something a sed should attempt.
	#    verified 2026-08-30 against the therock-10.0 rccl asset.
	grep -qE '^[[:space:]]*COMPONENT tests$' test/CMakeLists.txt ||
		die "CTestTestfile install anchor moved; it would be installed"
	sed -E -e 's/^([[:space:]]*)COMPONENT tests$/\1COMPONENT tests EXCLUDE_FROM_ALL/' \
		-i test/CMakeLists.txt || die

	# Warning suppression moved upstream: 10.0 removed the hardcoded
	# target_compile_options(rccl PRIVATE -Wall) this sed used to delete, and
	# added option(QUIET_WARNINGS ... OFF) instead -- upstream's own install.sh
	# passes -DQUIET_WARNINGS=ON. src_configure sets it, so the sed is gone
	# rather than left to match nothing. verified 2026-08-30.

	# allow to redefine CMAKE_INSTALL_LIBDIR from lib to $(get_libdir)
	# `sed` exits 0 on no-match: without this the FORCE keeps CMAKE_INSTALL_LIBDIR at lib and everything
	# installs to /usr/lib instead of $(get_libdir)
	grep -qF 'CMAKE_INSTALL_LIBDIR' cmake/Dependencies.cmake ||
		die "CMAKE_INSTALL_LIBDIR anchor moved in cmake/Dependencies.cmake"
	sed -e '/CMAKE_INSTALL_LIBDIR/ s/ FORCE//' -i cmake/Dependencies.cmake || die
	cmake_src_prepare
}

src_configure() {
	rocm_use_clang

	# lto flags make compilation fail with "undefined hidden symbol"
	filter-lto

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		# Replaces the old src_prepare sed that deleted a hardcoded -Wall;
		# 10.0 provides this option and upstream's install.sh passes it.
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
	# APU (as second device, if any) expectedly breaks tests
	HIP_VISIBLE_DEVICES=0 LD_LIBRARY_PATH="${BUILD_DIR}" edob test/rccl-UnitTests
}
