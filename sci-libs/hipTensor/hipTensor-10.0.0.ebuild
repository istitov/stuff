# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1

inherit cmake rocm

DESCRIPTION="High-performance tensor contraction, reduction and permutation library"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/hiptensor"
# New package; ::gentoo carries no hipTensor at any version. It is AMD's answer
# to cuTENSOR -- an einsum-style tensor contraction/reduction/permutation API
# implemented on top of sci-libs/composable-kernel's instance libraries.
#
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the 10.0
# source ships as the hiptensor.tar.gz asset on the rocm-libraries
# therock-<major.minor> release, the same shape sci-libs/rocPRIM uses.
SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/hiptensor.tar.gz -> hiptensor-${PV}.tar.gz"
S="${WORKDIR}/hiptensor"

LICENSE="MIT"
# Versioned by the ROCm release rather than upstream's rocm_setup_version(2.4.0),
# matching the rest of the stack.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

# From SUPPORTED_ARCHITECTURES in
# cmake/Functions/hiptensorSupportedArchitectures.cmake, minus the
# gfx11-generic/gfx12-generic entries, which are compiler pseudo-targets rather
# than anything amdgpu_targets_* can express. verified 2026-08-30.
IUSE_TARGETS=(
	gfx908 gfx90a gfx942 gfx950
	gfx1100 gfx1101 gfx1102 gfx1103 gfx1150 gfx1151 gfx1152 gfx1153
	gfx1200 gfx1201 gfx1250
)
IUSE_TARGETS=( "${IUSE_TARGETS[@]/#/amdgpu_targets_}" )
ROCM_USEDEP_OPTFLAGS=${IUSE_TARGETS[*]/%/(-)?}
ROCM_USEDEP=${ROCM_USEDEP_OPTFLAGS// /,}
ROCM_REQUIRED_USE=" || ( ${IUSE_TARGETS[*]} )"

IUSE="${IUSE_TARGETS[*]/#/+} test"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

RESTRICT="!test? ( test )"

# composable-kernel[hiptensor] is not a nicety: upstream does
#     find_package(composable_kernel 1.0.0 REQUIRED
#                  COMPONENTS device_contraction_operations
#                             device_reduction_operations
#                             device_other_operations)
# and a default composable-kernel build provides NONE of those three -- our
# ebuild passes MIOPEN_REQ_LIBS_ONLY=ON, which narrows the instance set to what
# MIOpen needs (conv + utility). USE=hiptensor there adds
# HIPTENSOR_REQ_LIBS_ONLY=ON, and the two filters compose to a union rather
# than conflicting, so MIOpen's set is unaffected. verified 2026-08-30.
#
# It is DEPEND-only, not RDEPEND, and that was checked against the built
# artifact rather than assumed: hipTensor compiles its OWN contraction
# instances from Composable Kernel's header-only templates (the link line is
# ~300 MB of device_contraction_*_instance.cpp.o), so nothing of CK survives
# into the shared object. libhiptensor.so.0.1 has NEEDED libamdhip64.so.7 and
# nothing else from ROCm, carries no libdevice_*/composable_kernel strings, has
# zero dlopen/dlsym relocations, and the installed hiptensor-config.cmake
# find_dependency()s only hip. verified 2026-08-31.
RDEPEND="
	dev-util/hip:${SLOT}
"
DEPEND="
	${RDEPEND}
	sci-libs/composable-kernel:${SLOT}[hiptensor]
"
BDEPEND="
	dev-build/rocm-cmake:${SLOT}
	test? ( dev-cpp/gtest )
"

# NOT USABLE ON RDNA at this release, verified 2026-08-31 on gfx1150: the
# package builds, installs and initialises, but hiptensorCreateContraction
# returns HIPTENSOR_STATUS_ARCH_MISMATCH. All 160 of the contraction instance
# sources under library/src/contraction/device are `_xdl_` -- CDNA matrix-core
# (MFMA) kernels -- and there is not one `_wmma_` or `_dl_` instance among
# them, so there are simply no kernels for an RDNA part to run. That matches
# upstream's own DEFAULT_ARCHITECTURES, which is gfx908/gfx90a/gfx942/gfx950
# plus the gfx11-/gfx12-generic pseudo-targets; the concrete RDNA entries in
# SUPPORTED_ARCHITECTURES buy a successful build, not working kernels.
#
# The RDNA amdgpu_targets_* flags below are kept anyway, because they mirror
# upstream's SUPPORTED_ARCHITECTURES and the package is genuinely functional on
# CDNA. Re-test contraction on a bump: WMMA instances appearing upstream is the
# thing to watch for.

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		-DHIPTENSOR_BUILD_TESTS=$(usex test ON OFF)
		-DHIPTENSOR_BUILD_SAMPLES=OFF
		-Wno-dev
	)

	# Only meaningful with tests on: HIPTENSOR_USE_SYSTEM_GOOGLETEST is declared
	# in test/CMakeLists.txt, which is add_subdirectory'd only when
	# HIPTENSOR_BUILD_TESTS is ON, so passing it unconditionally earns a
	# "CMake variables were not used by the project" QA notice. Without it the
	# test build FetchContent-clones googletest, which cannot work under
	# network-sandbox.
	use test && mycmakeargs+=( -DHIPTENSOR_USE_SYSTEM_GOOGLETEST=ON )

	cmake_src_configure
}

src_install() {
	# hipTensor has a STUB build mode: when its target list resolves to empty,
	# CMakeLists.txt sets HIPTENSOR_DISABLE_DEVICE=ON on its own, skips
	# library/src and the Composable Kernel dependency entirely, and emits a
	# host-only library that implements the whole public API but returns
	# HIPTENSOR_STATUS_NOT_SUPPORTED from every entry point. That is a warning,
	# not an error, so it would install and link perfectly happily.
	#
	# Passing a non-empty -DGPU_TARGETS above is what avoids it, but assert the
	# outcome rather than the input -- the stub is indistinguishable from the
	# real thing by file name alone.
	grep -q 'HIPTENSOR_DISABLE_DEVICE:.*=OFF' "${BUILD_DIR}"/CMakeCache.txt ||
		die "hipTensor fell back to its stub library -- no device backend was built"

	cmake_src_install
}
