# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Requires Clang 23 for new struct-buffer builtins and amdhsa_abi.h; Clang 22
# fails both. verified by compilation 2026-08-29
LLVM_COMPAT=( 23 )
inherit cmake flag-o-matic llvm-r2

# ROCm 10 uses therock-X.Y tags. This is a source archive, so MY_P must match its
# extracted tag-based directory; rocm-comgr shares the same DIST entry.
# verified 2026-08-29
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

# The old LLVM 22 OCKL attribute patch is upstream; revisit only if an OCKL
# builtin regains a bare attribute. verified 2026-08-29
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
	# Prefix the relative bitcode install path. Match its quotes exactly so the
	# already-correct Clang resource path does not become lib/lib; the old broad
	# sed caused that latent error. verified 2026-08-30
	grep -q '"amdgcn/bitcode"' cmake/OCL.cmake ||
		die "amdgcn/bitcode anchor moved in OCL.cmake"
	sed -e 's:"amdgcn/bitcode":"lib/amdgcn/bitcode":' \
		-i cmake/OCL.cmake || die
	# Guard against a silent no-match and nonstandard docdir. verified 2026-08-30
	# shellcheck disable=SC2016
	grep -q '${CMAKE_INSTALL_DATADIR}/doc/${CPACK_PACKAGE_NAME}' CMakeLists.txt ||
		die "docdir anchor moved in CMakeLists.txt; docs would install outside the standard docdir"
	# shellcheck disable=SC2016
	sed -e 's:${CMAKE_INSTALL_DATADIR}/doc/${CPACK_PACKAGE_NAME}:${CMAKE_INSTALL_DOCDIR}:' \
		-i CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	# Pin Clang: newer defaults emit bitcode consumers cannot link.
	llvm_prepend_path "${LLVM_SLOT}"
	local -x CC=${CHOST}-clang
	local -x CXX=${CHOST}-clang++
	# Filter flags after switching compilers. bug #936099
	strip-unsupported-flags

	cmake_src_configure
}

src_install() {
	cmake_src_install
	# Let Clang discover the device libs without --rocm-device-lib-path.
	local bitcodedir="$(clang -print-resource-dir)/$(get_libdir)/amdgcn/bitcode"
	dosym -r "/usr/lib/amdgcn/bitcode" "${bitcodedir#"${EPREFIX}"}"
}

src_test() {
	# Unsupported-GPU tests. upstream issue #76
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
