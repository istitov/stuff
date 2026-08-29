# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Tracks the ROCm 10.0 cohort's LLVM slot. The stack is subslot-pinned as a
# single dependency closure, so all of it must be compiled by one LLVM major.
LLVM_COMPAT=( 23 )

inherit cmake flag-o-matic llvm-r2

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/ROCm/ROCR-Runtime/"
	inherit git-r3
	S="${WORKDIR}/${P}"
else
	# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the same
	# per-component assets ship under therock-<major.minor> tags now. ROCm 10.0
	# is the renumbering of the 7.13 -> 7.14 line (2026-08-27).
	SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/${PN}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/rocr-runtime"
	KEYWORDS="~amd64"
fi

DESCRIPTION="Radeon Open Compute Runtime"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocr-runtime"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
IUSE="debug"

COMMON_DEPEND="dev-libs/elfutils
	x11-libs/libdrm"
DEPEND="${COMMON_DEPEND}
	dev-libs/roct-thunk-interface:${SLOT}
	dev-libs/rocm-device-libs:${SLOT}
		$(llvm_gen_dep "
			llvm-core/clang:\${LLVM_SLOT}=
			llvm-core/lld:\${LLVM_SLOT}=
			llvm-core/llvm:\${LLVM_SLOT}=
		")
"
RDEPEND="${DEPEND}"
BDEPEND="app-editors/vim-core"
	# vim-core is needed for "xxd"

# ${PN}-7.2.0-fix-libcxx.patch is NOT carried: it added an explicit
# HsaSignalLess comparator for std::map<hsa_signal_t, ...> because libc++
# rejects the default std::less<void> on hsa_signal_t (rocm-systems#3307).
# 10.0 ships it upstream -- core/inc/amd_gpu_agent.h defines `struct
# HsaSignalLess` and uses it in the scratch_notifiers_ declaration -- so the
# hunk no longer applies. verified 2026-08-29 against the therock-10.0 tree.
# use-system-hsakmt still applies (offset 4 lines) and is still required: it
# is what makes the build use dev-libs/roct-thunk-interface instead of the
# vendored libhsakmt.
PATCHES=(
	"${FILESDIR}/${PN}-7.2.0-use-system-hsakmt.patch"
)

# skip false positive detection in samples, bug #958188
CMAKE_QA_COMPAT_SKIP=1

src_prepare() {
	cd "${S}/runtime/hsa-runtime" || die

	# Gentoo installs "*.bc" to "/usr/lib" instead of a "[path]/bitcode" directory ...
	# Anchored on a bare "-O2", which is brittle; `sed` exits 0 on no-match so
	# `|| die` cannot catch it drifting. Assert first. verified 2026-08-29:
	# still exactly one occurrence at therock-10.0.
	grep -q -- '-O2' image/blit_src/CMakeLists.txt ||
		die "blit_src -O2 anchor moved; device bitcode path would not be set"
	sed -e "s:-O2:--rocm-path=${EPREFIX}/usr/lib/ -O2:" -i image/blit_src/CMakeLists.txt || die

	cd "${S}" || die

	# 10.0 sources include "hsakmt/linux/kfd_ioctl.h" (libamdhsacode/lnx/
	# amd_core_dump.cpp), but libhsakmt's own CMake install rule EXCLUDES that
	# subdirectory on purpose:
	#   install ( DIRECTORY .../include/hsakmt ... PATTERN "linux" EXCLUDE ... )
	# so dev-libs/roct-thunk-interface cannot provide it and upstream never
	# meant it to be a public header. Upstream builds rocr-runtime and
	# libhsakmt in ONE tree and resolves it from source; our split build (see
	# use-system-hsakmt.patch) does not.
	#
	# This tarball ships libhsakmt/ itself, so the header is already here.
	# Expose ONLY the linux/ subdir through a private include root -- pointing
	# -I at libhsakmt/include wholesale would shadow the system hsakmt headers
	# and silently undo use-system-hsakmt. verified 2026-08-29.
	local kfd_inc="${WORKDIR}/hsakmt-private-include"
	mkdir -p "${kfd_inc}/hsakmt" || die
	[[ -f libhsakmt/include/hsakmt/linux/kfd_ioctl.h ]] ||
		die "bundled libhsakmt no longer ships hsakmt/linux/; re-check this workaround"
	cp -r libhsakmt/include/hsakmt/linux "${kfd_inc}/hsakmt/" || die
	append-cppflags "-I${kfd_inc}"

	cmake_src_prepare
}

src_configure() {
	# -Werror=odr
	# https://bugs.gentoo.org/856091
	# https://github.com/ROCm/ROCR-Runtime/issues/182
	filter-lto

	use debug || append-cxxflags "-DNDEBUG"

	local mycmakeargs=(
		-DCMAKE_DISABLE_FIND_PACKAGE_rocprofiler-register=ON
		-Wno-dev
	)

	cmake_src_configure
}
