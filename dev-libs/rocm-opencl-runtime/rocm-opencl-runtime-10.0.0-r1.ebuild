# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1
inherit cmake edo flag-o-matic rocm

DESCRIPTION="Radeon Open Compute OpenCL Compatible Runtime"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/clr"

# AMD retired rocm-* releases; use the matching TheRock clr asset shared with
# dev-util/hip.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/clr.tar.gz -> rocm-clr-${PV}.tar.gz"
S="${WORKDIR}/clr"

LICENSE="Apache-2.0 MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"
IUSE="debug numa test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/rocr-runtime:${SLOT}
	dev-libs/rocm-comgr:${SLOT}
	dev-libs/rocm-device-libs:${SLOT}
	>=virtual/opencl-3
	media-libs/mesa[-opencl]
	numa? ( sys-process/numactl )
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-build/rocm-cmake:${SLOT}
	media-libs/glew
	test? ( >=x11-apps/mesa-progs-8.5.0[X] )
"

PATCHES=(
	"${FILESDIR}/${PN}-6.2.4-fix-lib-version.patch"
	# Prevent clCreateCommandQueue() from crashing on AVX-512; shared with HIP's
	# VirtualGPU build.
	"${FILESDIR}/${PN}-10.0.0-aligned-new.patch"
)

src_unpack() {
	# Preserve the archive's clr/ top-level directory expected by S.
	unpack "rocm-clr-${PV}.tar.gz"
}

src_prepare() {
	# Raise vendored Khronos' obsolete CMake floor; assert both 3.5 anchors.
	# verified 2026-08-29
	local f
	for f in opencl/khronos/icd/CMakeLists.txt \
		opencl/khronos/headers/opencl2.2/tests/CMakeLists.txt; do
		grep -q 'cmake_minimum_required.*3\.5' "${f}" ||
			die "cmake_minimum_required 3.5 anchor moved in ${f}"
	done
	sed -e "/cmake_minimum_required/ s/3\.5/3.10/" \
		-i opencl/khronos/icd/CMakeLists.txt opencl/khronos/headers/opencl2.2/tests/CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	# Avoid strict-aliasing and LTO failures (bug #856088, ROCm/clr#64).
	append-flags -fno-strict-aliasing
	filter-lto

	# Fix the ld.lld link (ROCm-OpenCL-Runtime#155).
	append-ldflags $(test-flags-CCLD -Wl,--undefined-version)

	# Restore legacy common symbols (ROCm-OpenCL-Runtime#120).
	append-cflags -fcommon

	local mycmakeargs=(
		-Wno-dev
		-DROCM_PATH="${EPREFIX}/usr"
		-DBUILD_TESTS=$(usex test ON OFF)
		-DEMU_ENV=ON
		-DBUILD_ICD=ON
		-DCLR_BUILD_OCL=ON
		-DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
		# NUMA discovery remains absent, so these are inert; retain for a future
		# restoration. # verified 2026-09-10 against TheRock 10.0
		-DCMAKE_DISABLE_FIND_PACKAGE_NUMA="$(usex !numa)"
		-DCMAKE_REQUIRE_FIND_PACKAGE_NUMA="$(usex numa)"
	)
	cmake_src_configure
}

src_install() {
	insinto /etc/OpenCL/vendors
	doins opencl/config/amdocl64.icd

	cd "${BUILD_DIR}"/opencl || die
	insinto /usr/lib64
	doins amdocl/libamdocl64.so*
	doins tools/cltrace/libcltrace.so
}

src_test() {
	check_amdgpu
	cd "${BUILD_DIR}"/tests/ocltst || die
	export OCL_ICD_FILENAMES="${BUILD_DIR}"/amdocl/libamdocl64.so
	local instruction1="Please start an X server using amdgpu driver (not Xvfb!),"
	local instruction2="and export OCLGL_DISPLAY=\${DISPLAY} OCLGL_XAUTHORITY=\${XAUTHORITY} before reruning the test."
	if [[ -n ${OCLGL_DISPLAY+x} ]]; then
		export DISPLAY=${OCLGL_DISPLAY}
		export XAUTHORITY=${OCLGL_XAUTHORITY}
		ebegin "Running oclgl test under DISPLAY ${OCLGL_DISPLAY}"
		if ! glxinfo | grep "OpenGL vendor string: AMD"; then
			ewarn "${instruction1}"
			ewarn "${instruction2}"
			die "This display does not have AMD OpenGL vendor!"
		fi
		./ocltst -m $(realpath liboclgl.so) -A ogl.exclude
		eend $? || die "oclgl test failed"
	else
		ewarn "${instruction1}"
		ewarn "${instruction2}"
		die "\${OCLGL_DISPLAY} not set."
	fi
	edob ./ocltst -m $(realpath liboclruntime.so) -A oclruntime.exclude
	edob ./ocltst -m $(realpath liboclperf.so) -A oclperf.exclude
}
