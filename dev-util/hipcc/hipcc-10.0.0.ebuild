# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Match the ROCm 10 compiler cohort: device-libs needs Clang 23 APIs, while a
# hipcc wired to 22 still builds successfully in isolation. verified 2026-08-29
LLVM_COMPAT=( 23 )
inherit cmake llvm-r2

DESCRIPTION="Radeon Open Compute hipcc"
HOMEPAGE="https://github.com/ROCm/llvm-project/tree/amd-staging/amd/hipcc"

# ROCm 10 uses therock-X.Y tags, which also name the extracted directory.
# verified 2026-08-28
MY_P=llvm-project-therock-$(ver_cut 1-2)
components=( "amd/hipcc" )
if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/ROCm/llvm-project"
	inherit git-r3
	S="${WORKDIR}/${P}/${components[0]}"
else
	SRC_URI="https://github.com/ROCm/llvm-project/archive/therock-$(ver_cut 1-2).tar.gz -> ${MY_P}.tar.gz"
	S="${WORKDIR}/${MY_P}/${components[0]}"
	KEYWORDS="~amd64"
fi

LICENSE="Apache-2.0 MIT"
SLOT="0/$(ver_cut 1-2)"
# amd-llvm redirects hipconfig to AMD's fork; rocm_use_clang then propagates it
# across the stack. The fork supplies required bf16 WMMA signatures and accepts
# AMDGPU source modifiers rejected by vanilla LLVM. verified 2026-08-29
IUSE="amd-llvm debug"

DEPEND="
	amd-llvm? ( llvm-core/rocm-llvm:${SLOT} )
	$(llvm_gen_dep "
		llvm-runtimes/compiler-rt:\${LLVM_SLOT}=
		llvm-core/llvm:\${LLVM_SLOT}=
		llvm-core/clang:\${LLVM_SLOT}=
	")
"
RDEPEND="${DEPEND}"

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
	cmake_src_prepare

	# ROCm 10 constructs the compiler path component-by-component; patch the
	# exact llvm component for Gentoo's layout and guard the silent sed miss.
	# verified 2026-08-29
	grep -qF 'hipClangPath /= "llvm";' src/hipBin_amd.h ||
		die "constructCompilerPath component-append anchor moved; hipcc would not find clang"
	if use amd-llvm; then
		# AMD's fork uses an unversioned /usr/lib/rocm-llvm.
		sed -e "s:hipClangPath /= \"llvm\";:hipClangPath /= \"rocm-llvm\";:" \
			-i src/hipBin_amd.h || die
	else
		sed -e "s:hipClangPath /= \"llvm\";:hipClangPath /= \"llvm\";\n  hipClangPath /= \"${LLVM_SLOT}\";:" \
			-i src/hipBin_amd.h || die
	fi

	# Correct the remaining help-text prefix and guard its location.
	# verified 2026-08-30
	grep -q '/opt/rocm' src/hipBin_base.h ||
		die "/opt/rocm anchor moved in hipBin_base.h"
	sed -e "s:/opt/rocm:/usr:g" -i src/hipBin_base.h || die

	# Prefix the sole bitcode path for Gentoo; a silent miss breaks every device
	# compile. No pre-prefixed occurrence can be doubled. verified 2026-08-30
	grep -qF '"amdgcn/bitcode"' src/hipBin_amd.h ||
		die "amdgcn/bitcode anchor moved in hipBin_amd.h; hipcc would not find the device libs"
	sed -e "s:amdgcn/bitcode:lib/amdgcn/bitcode:g" \
		-i src/hipBin_amd.h || die
}

src_install() {
	cmake_src_install
	rm -rf "${ED}/usr/hip" || die
}
