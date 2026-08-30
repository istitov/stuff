# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ROCm 10.0 requires clang 23, not 22: ockl/src/image.cl calls
# __builtin_amdgcn_struct_buffer_{load,store}_format_v4f{16,32}, which clang 22
# rejects as undeclared identifiers, and workitem.cl includes <amdhsa_abi.h>,
# a clang 23 addition (shipped in the resource dir, /usr/lib/clang/23/include).
# verified 2026-08-29 by compiling both against clang 22 and 23.
LLVM_COMPAT=( 23 )
inherit cmake flag-o-matic llvm-r2

# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); everything
# since is tagged therock-<major.minor>, on ROCm/llvm-project as well as on the
# two component monorepos. ROCm 10.0 is the renumbering of the 7.13 -> 7.14
# line announced 2026-08-27, not a jump of three majors.
#
# Unlike the rocm-systems packages -- which fetch a per-component release ASSET
# whose name is tag-independent -- this one fetches a GitHub source ARCHIVE, so
# the tag is baked into the extracted top-level directory too: therock-10.0
# unpacks as llvm-project-therock-10.0/, not llvm-project-rocm-10.0.0/. MY_P
# therefore tracks the tag, not ${PV}, and the distfile is named for the tag it
# actually is. dev-libs/rocm-comgr fetches the same archive and must use the
# identical MY_P so the two keep sharing one DIST entry.
# verified 2026-08-29: therock-10.0 exists on ROCm/llvm-project and carries
# amd/device-libs.
MY_P=llvm-project-therock-$(ver_cut 1-2)
components=( "amd/device-libs" )

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/ROCm/llvm-project"
	inherit git-r3
	S="${WORKDIR}/${P}/${components[0]}"
else
	SRC_URI="https://github.com/ROCm/llvm-project/archive/therock-$(ver_cut 1-2).tar.gz -> ${MY_P}.tar.gz"
	S="${WORKDIR}/${MY_P}/${components[0]}"
	KEYWORDS="~amd64"
fi

DESCRIPTION="Radeon Open Compute Device Libraries"
HOMEPAGE="https://github.com/ROCm/llvm-project/tree/amd-staging/amd/device-libs"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	dev-build/rocm-cmake:${SLOT}
	$(llvm_gen_dep "
		llvm-core/clang:\${LLVM_SLOT}
		llvm-core/lld:\${LLVM_SLOT}
		llvm-core/llvm:\${LLVM_SLOT}
	")
"

CMAKE_BUILD_TYPE=Release

# ${PN}-7.2.0-llvm-22-compat.patch is NOT applied here: it backported
# amd-staging's target("...") attributes onto the ockl builtins that LLVM 22
# refuses to emit without them, and ROCm 10.0 ships those upstream already --
# ockl/src/media.cl defines LCATTR/QCATTR/SCATTR and ockl/src/image.cl defines
# CRATTR natively. Upstream in fact went further and gave RATTR itself
# target("image-insts"), which is why 4 of the patch's 5 hunks no longer apply.
# Re-check on the next bump only if an ockl builtin regains a bare attribute.
# verified 2026-08-29 against the therock-10.0 tree.
PATCHES=(
	"${FILESDIR}/${PN}-6.2.0-test-bitcode-dir.patch"
)

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
	# INSTALL_ROOT_SUFFIX is relative to CMAKE_INSTALL_PREFIX, so upstream's
	# bare "amdgcn/bitcode" would install to /usr/amdgcn/bitcode. Prefix it.
	#
	# Anchor on the quotes. This is a fix, not just a hardening. OCL.cmake
	# assigns INSTALL_ROOT_SUFFIX three times:
	#
	#   :52  "amdgcn/bitcode"                          <- the one to prefix
	#   :55  "${..._INSTALL_LOC_NEW}/bitcode"          <- no amdgcn, never matched
	#   :66  "${CLANG_RSRC_DIR}/lib/amdgcn/bitcode"    <- already correct
	#
	# The old unanchored `s:amdgcn/bitcode:lib/amdgcn/bitcode:` hit :66 as well
	# and rewrote it to ".../lib/lib/amdgcn/bitcode". That stayed latent only
	# because :66 sits behind ROCM_DEVICE_LIBS_BITCODE_INSTALL_LOC_CLANG_RESOURCE_DIR,
	# which defaults OFF; turn it on and clang looks for the device libs one
	# directory above where they landed.
	#
	# cmake/Packages.cmake was in this list through 7.2.4 but carries no
	# amdgcn/bitcode reference at 10.0, so listing it was a silent no-op.
	# verified 2026-08-30 against the therock-10.0 source.
	grep -q '"amdgcn/bitcode"' cmake/OCL.cmake ||
		die "amdgcn/bitcode anchor moved in OCL.cmake"
	sed -e 's:"amdgcn/bitcode":"lib/amdgcn/bitcode":' \
		-i cmake/OCL.cmake || die
	# shellcheck disable=SC2016
	sed -e 's:${CMAKE_INSTALL_DATADIR}/doc/${CPACK_PACKAGE_NAME}:${CMAKE_INSTALL_DOCDIR}:' \
		-i CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	# Do not trust CMake with autoselecting Clang, as it autoselects the latest one
	# producing too modern LLVM bitcode and causing linker errors in other packages.
	llvm_prepend_path "${LLVM_SLOT}"
	local -x CC=${CHOST}-clang
	local -x CXX=${CHOST}-clang++
	# Clean up unsupported flags for the switched compiler, see #936099
	strip-unsupported-flags

	cmake_src_configure
}

src_install() {
	cmake_src_install
	# install symlink, so that clang won't ask for "--rocm-device-lib-path" flag anymore
	local bitcodedir="$(clang -print-resource-dir)/$(get_libdir)/amdgcn/bitcode"
	dosym -r "/usr/lib/amdgcn/bitcode" "${bitcodedir#"${EPREFIX}"}"
}

src_test() {
	# https://github.com/ROCm/llvm-project/issues/76
	# "Failing tests are on gfx that are not supported"
	local CMAKE_SKIP_TESTS=(
		compile_frexp__gfx600
		compile_fract__gfx600
		compile_native_rcp__gfx600
		compile_native_rsqrt__gfx600
		compile_fract__gfx700
		compile_native_rcp__gfx700
		compile_native_rsqrt__gfx700
		compile_native_rcp__gfx803
		compile_native_rsqrt__gfx803
		compile_atomic_work_item_fence__*
	)

	cmake_src_test
}
