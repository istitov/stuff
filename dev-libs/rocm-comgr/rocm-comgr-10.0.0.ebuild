# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Tracks the ROCm 10.0 cohort's LLVM slot. The stack is subslot-pinned as a
# single dependency closure, so all of it must be compiled by one LLVM major.
LLVM_COMPAT=( 23 )

inherit cmake llvm-r2

# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); everything
# since is tagged therock-<major.minor>. This package fetches a GitHub source
# ARCHIVE, so the tag also spells the extracted top-level directory. MY_P must
# stay byte-identical to dev-libs/rocm-device-libs-10.0.0's so the two keep
# sharing a single DIST entry -- they unpack disjoint subdirs of one tarball.
MY_P=llvm-project-therock-$(ver_cut 1-2)
components=( "amd/comgr" )

DESCRIPTION="Radeon Open Compute Code Object Manager"
HOMEPAGE="https://github.com/ROCm/llvm-project/tree/amd-staging/amd/comgr"
SRC_URI="https://github.com/ROCm/llvm-project/archive/therock-$(ver_cut 1-2).tar.gz -> ${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}/${components[0]}"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="test"
RESTRICT="!test? ( test )"

# ${PN}-7.2.0-llvm-22-compat.patch is deliberately NOT applied here, and it is
# not merely obsolete -- carrying it would BREAK the build:
#   hunk 1 (setFileManager -> setVirtualFileSystem) is upstream in 10.0
#           (src/comgr-compiler.cpp already calls setVirtualFileSystem(FS)), so
#           it no longer applies;
#   hunk 2 rewrote "-Xclang -no-disable-free" to "-disable-free=false", but
#           clang 23 ACCEPTS the former and REJECTS the latter with
#           "error: unknown argument: '-disable-free=false'".
# Verified 2026-08-29 by compiling a TU against clang 23 with each spelling.
# The other two patches were dry-run against the therock-10.0 tree and still
# apply cleanly.
PATCHES=(
	"${FILESDIR}/${PN}-6.4.1-extend-isa-compatibility-check.patch"
	"${FILESDIR}/${PN}-6.1.0-dont-add-nogpulib.patch"
	"${FILESDIR}/${PN}-10.0.0-add-missing-headers.patch"
	"${FILESDIR}/${PN}-10.0.0-hotswap-llvm-dylib.patch"
)

RDEPEND="
	dev-libs/rocm-device-libs:${SLOT}
	llvm-runtimes/clang-runtime:=
	$(llvm_gen_dep "
		llvm-core/clang:\${LLVM_SLOT}=
		llvm-core/lld:\${LLVM_SLOT}=
		llvm-core/llvm:\${LLVM_SLOT}=
	")
	dev-util/hipcc:${SLOT}
"
DEPEND="${RDEPEND}"

# Circular dependency: to build tests, hip compiler must be functional
BDEPEND="test? ( dev-util/hip:${SLOT} )"

CMAKE_BUILD_TYPE=Release

src_unpack() {
	if [[ ${PV} == *9999 ]] ; then
		git-r3_fetch
		git-r3_checkout '' . '' "${components[@]}"
	else
		archive="${MY_P}.tar.gz"
		ebegin "Unpacking from ${archive}"
		tar -x -z -o \
			-f "${DISTDIR}/${archive}" \
			"${components[@]/#/${MY_P}/}" || die
		eend ${?}
	fi
}

src_prepare() {
	# `sed` exits 0 when it matches nothing, so `|| die` cannot catch a stale
	# anchor -- assert the pattern is present first. verified 2026-08-29:
	# cmake/opencl_header.cmake still carries it twice at therock-10.0.
	grep -q 'CLANG_CMAKE_DIR}/\.\./\.\./\.\./\*' cmake/opencl_header.cmake ||
		die "opencl_header.cmake anchor moved; re-check the sed below"
	sed -e "s:\${CLANG_CMAKE_DIR}/../../../\*:${EPREFIX}/usr/lib/clang/${LLVM_SLOT}/include:" \
		-i cmake/opencl_header.cmake || die

	# The llvm-22 sed backport that used to live here (Driver/Options.h ->
	# Options/Options.h, clang::driver::options -> clang::options,
	# Driver::GetResourcesPath -> GetResourcesPath) is GONE: all three are
	# upstream in 10.0 -- src/comgr-compiler.cpp already includes
	# "clang/Options/Options.h" and has zero occurrences of the old spellings.
	# Left in place it would have silently matched nothing forever.
	# verified 2026-08-29.

	cmake_src_prepare
}

src_configure() {
	llvm_prepend_path "${LLVM_SLOT}"

	local mycmakeargs=(
		-DCMAKE_STRIP=""  # disable stripping defined at lib/comgr/CMakeLists.txt:58
		-DBUILD_TESTING=$(usex test ON OFF)
		-DCOMGR_DISABLE_SPIRV=ON  # requires ROCm/SPIRV-LLVM-Translator (fork of dev-util/spirv-llvm-translator)
	)
	# Prevent CMake from finding systemwide hip, which breaks tests
	use test && mycmakeargs+=( -DCMAKE_DISABLE_FIND_PACKAGE_hip=ON )
	cmake_src_configure
}

src_test() {
	cmake_src_test
}
