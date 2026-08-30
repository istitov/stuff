# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Tracks the ROCm 10.0 cohort's LLVM slot. The stack is subslot-pinned as a
# single dependency closure, so all of it must be compiled by one LLVM major.
LLVM_COMPAT=( 23 )

inherit cmake flag-o-matic llvm-r2

DESCRIPTION="A set of tools to translate CUDA source code into portable HIP C++"
HOMEPAGE="https://github.com/ROCm/HIPIFY"
# HIPIFY is the ONE stack component that still lives in its own repo at 10.0.
# rccl, rocRAND, rocSOLVER, rocSPARSE and rocThrust were all folded into the
# rocm-libraries / rocm-systems monorepos and have no therock-* tags at all,
# but ROCm/HIPIFY kept its own and publishes therock-<major.minor> there. So
# this one keeps the git-archive shape and only the tag moves -- which also
# spells the extracted directory, hence the S= change.
# verified 2026-08-29: ROCm/HIPIFY carries tag therock-10.0.
SRC_URI="https://github.com/ROCm/HIPIFY/archive/therock-$(ver_cut 1-2).tar.gz -> HIPIFY-${PV}.tar.gz"
S="${WORKDIR}/HIPIFY-therock-$(ver_cut 1-2)"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

DEPEND="
	$(llvm_gen_dep "
		llvm-core/clang:\${LLVM_SLOT}=
		llvm-core/llvm:\${LLVM_SLOT}=
	")
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-7.0.1-fix-clang-libs.patch"
)

src_prepare() {
	cmake_src_prepare

	# Set clang resource prefix to /usr/lib/clang/...
	# `sed` exits 0 on no-match: leaves hipify looking for clang headers under the wrong prefix
	grep -qF '/lib/llvm/lib/clang/' src/main.cpp ||
		die "/lib/llvm/lib/clang/ anchor moved in src/main.cpp"
	sed -i 's:/lib/llvm/lib/clang/:/lib/clang/:' src/main.cpp || die
}

src_configure() {
	# 928906: CMakeLists.txt ignores CC/CXX, switches compiler to clang
	# and fails if non-compatible CFLAGS/CXXFLAGS are used
	strip-unsupported-flags

	local mycmakeargs=(
		-DCMAKE_PREFIX_PATH="$(get_llvm_prefix)/$(get_libdir)/cmake/llvm"
	)

	cmake_src_configure
}
