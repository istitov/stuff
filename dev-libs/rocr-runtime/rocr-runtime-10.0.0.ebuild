# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Keep the subslot-pinned ROCm closure on one LLVM major.
LLVM_COMPAT=( 23 )

inherit cmake flag-o-matic llvm-r2

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/ROCm/ROCR-Runtime/"
	inherit git-r3
	S="${WORKDIR}/${P}"
else
	# AMD retired rocm-* releases; use the matching TheRock component asset.
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
# xxd provider.
BDEPEND="app-editors/vim-core"

# Force dev-libs/roct-thunk-interface instead of vendored libhsakmt.
PATCHES=(
	"${FILESDIR}/${PN}-7.2.0-use-system-hsakmt.patch"
)

# Skip false-positive sample detection (bug #958188).
CMAKE_QA_COMPAT_SKIP=1

src_prepare() {
	cd "${S}/runtime/hsa-runtime" || die

	# Point device bitcode at /usr/lib; assert the brittle -O2 anchor first.
	# verified 2026-08-29
	grep -q -- '-O2' image/blit_src/CMakeLists.txt ||
		die "blit_src -O2 anchor moved; device bitcode path would not be set"
	sed -e "s:-O2:--rocm-path=${EPREFIX}/usr/lib/ -O2:" -i image/blit_src/CMakeLists.txt || die

	cd "${S}" || die

	# rocr needs hsakmt/linux/kfd_ioctl.h, which the system package deliberately
	# omits. Expose only the bundled linux/ subtree; a broader include path would
	# shadow system hsakmt and undo the patch. # verified 2026-08-29
	local kfd_inc="${WORKDIR}/hsakmt-private-include"
	mkdir -p "${kfd_inc}/hsakmt" || die
	[[ -f libhsakmt/include/hsakmt/linux/kfd_ioctl.h ]] ||
		die "bundled libhsakmt no longer ships hsakmt/linux/; re-check this workaround"
	cp -r libhsakmt/include/hsakmt/linux "${kfd_inc}/hsakmt/" || die
	append-cppflags "-I${kfd_inc}"

	cmake_src_prepare
}

src_configure() {
	# LTO triggers -Werror=odr (bug #856091; upstream issue #182).
	filter-lto

	use debug || append-cxxflags "-DNDEBUG"

	local mycmakeargs=(
		-DCMAKE_DISABLE_FIND_PACKAGE_rocprofiler-register=ON
		-Wno-dev
	)

	cmake_src_configure
}
