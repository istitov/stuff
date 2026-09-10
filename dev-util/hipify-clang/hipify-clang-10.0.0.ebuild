# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Keep ROCm 10's subslot-pinned stack on one LLVM major.
LLVM_COMPAT=( 23 )

inherit cmake flag-o-matic llvm-r2

DESCRIPTION="A set of tools to translate CUDA source code into portable HIP C++"
HOMEPAGE="https://github.com/ROCm/HIPIFY"
# HIPIFY retains its standalone repository and therock tag at ROCm 10.
# verified 2026-08-29
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

	# Correct the Clang resource prefix; guard against a silently stale sed.
	grep -qF '/lib/llvm/lib/clang/' src/main.cpp ||
		die "/lib/llvm/lib/clang/ anchor moved in src/main.cpp"
	sed -i 's:/lib/llvm/lib/clang/:/lib/clang/:' src/main.cpp || die
}

src_configure() {
	# Upstream forces Clang and rejects incompatible flags (Gentoo bug 928906).
	strip-unsupported-flags

	local mycmakeargs=(
		-DCMAKE_PREFIX_PATH="$(get_llvm_prefix)/$(get_libdir)/cmake/llvm"
	)

	cmake_src_configure
}
