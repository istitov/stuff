# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_P=llvm-project-therock-${PV%.0}
components=( "amd/comgr" )

DESCRIPTION="Radeon Open Compute Code Object Manager"
HOMEPAGE="https://github.com/ROCm/llvm-project/tree/amd-staging/amd/comgr"
SRC_URI="https://github.com/ROCm/llvm-project/archive/therock-${PV%.0}.tar.gz -> ${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}/${components[0]}"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

# The unit tests need ::gentoo's LLVM_LINK_LLVM_DYLIB gtest fix, which does
# not apply to the 10.2 test tree. verified 2026-11-18
RESTRICT="test"

# 10.2 dropped the per-ISA table: comgr-metadata.cpp calls AMDGPU
# TargetParser helpers (getSGPRAllocGranule, getTotalNumSGPRs and others)
# that only LLVM 24 provides, so Comgr links AMD's LLVM from
# llvm-core/rocm-llvm instead of the system LLVM 23. verified 2026-11-18
ROCM_LLVM="/usr/lib/rocm-llvm"

PATCHES=(
	"${FILESDIR}/${PN}-6.4.1-extend-isa-compatibility-check.patch"
	"${FILESDIR}/${PN}-10.2.0-rocm-llvm-resource-dir.patch"
)

RDEPEND="
	dev-libs/rocm-device-libs:${SLOT}
	llvm-core/rocm-llvm:${SLOT}
	dev-util/hipcc:${SLOT}
"
DEPEND="${RDEPEND}"

CMAKE_BUILD_TYPE=Release

src_unpack() {
	archive="${MY_P}.tar.gz"
	ebegin "Unpacking from ${archive}"
	tar -x -z -o \
		-f "${DISTDIR}/${archive}" \
		"${components[@]/#/${MY_P}/}" || die
	eend ${?}
}

src_prepare() {
	cmake_src_prepare

	sed -i "s:@ROCM_LLVM_PREFIX@:${EPREFIX}${ROCM_LLVM}:" src/comgr-env.cpp || die
	grep -q "${EPREFIX}${ROCM_LLVM}" src/comgr-env.cpp ||
		die "rocm-llvm prefix not substituted into comgr-env.cpp"
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_STRIP=""  # disable stripping defined at lib/comgr/CMakeLists.txt:58
		-DBUILD_TESTING=OFF
		-DCOMGR_DISABLE_SPIRV=ON  # requires ROCm/SPIRV-LLVM-Translator (fork of dev-util/spirv-llvm-translator)
		-DCMAKE_PREFIX_PATH="${EPREFIX}${ROCM_LLVM}"
		-DLLVM_DIR="${EPREFIX}${ROCM_LLVM}/lib/cmake/llvm"
		-DClang_DIR="${EPREFIX}${ROCM_LLVM}/lib/cmake/clang"
		-DLLD_DIR="${EPREFIX}${ROCM_LLVM}/lib/cmake/lld"
		# rocm-llvm stays out of the linker path; reach its libLLVM.so this way.
		-DCMAKE_INSTALL_RPATH="${EPREFIX}${ROCM_LLVM}/lib"
	)
	cmake_src_configure
}
