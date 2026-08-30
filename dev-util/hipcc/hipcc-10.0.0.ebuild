# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Must track the slot the rest of the ROCm 10.0 cohort builds against, not the
# 22 inherited from 7.2.4: src_prepare seds lib/llvm/${LLVM_SLOT}/bin into the
# installed hipcc wrapper, so a 22 here would ship a hipcc driving clang 22
# while dev-libs/rocm-device-libs-10.0.0 requires clang 23 (it needs
# amdhsa_abi.h and the struct_buffer_load_format builtins, both LLVM 23
# additions). The mismatch builds fine in isolation, which is exactly why it
# has to be caught here rather than by a build-check. verified 2026-08-29.
LLVM_COMPAT=( 23 )
inherit cmake llvm-r2

DESCRIPTION="Radeon Open Compute hipcc"
HOMEPAGE="https://github.com/ROCm/llvm-project/tree/amd-staging/amd/hipcc"

# AMD retired the rocm-* tag line at rocm-7.2.4 (2026-05-28); every ROCm repo,
# llvm-project included, has published under therock-<major.minor> since. ROCm
# 10.0 is the renumbering of the 7.13 -> 7.14 line (2026-08-27), not a jump of
# three majors. The tag carries only major.minor and also spells the extracted
# directory, so MY_P tracks it too. verified 2026-08-28.
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
# amd-llvm: point hipcc at llvm-core/rocm-llvm (AMD's LLVM fork) instead of the
# system clang. This is the single lever that switches the whole ROCm library
# stack over: rocm.eclass's rocm_use_clang() derives CC/CXX from
# `hipconfig --hipclangpath`, so every library that calls it -- composable-
# kernel, hipBLASLt, rocBLAS, rocPRIM, rocRAND, rccl, Tensile, roctracer --
# follows automatically with no per-ebuild change.
#
# Needed because the ROCm math libraries cannot be compiled by a vanilla LLVM:
# AMD's fork gives the WMMA intrinsics bf16 signatures and its assembler
# accepts AMDGPU source modifiers that vanilla rejects. Verified 2026-08-29
# with minimal reproducers for both.
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

	# Point hipcc at Gentoo's SLOTTED clang. Through 7.2.4 the compiler path
	# was a literal "lib/llvm/bin" string and a plain substitution sufficed.
	# ROCm 10.0 rewrote HipBinAmd::constructCompilerPath() to append path
	# components one at a time:
	#     hipClangPath /= "lib"; hipClangPath /= "llvm"; hipClangPath /= "bin";
	# so the old anchor matches NOTHING in hipBin_amd.h and only a comment in
	# hipBin_base.h. `sed` exits 0 on no-match, so the ebuild still built and
	# installed a hipcc that probes /usr/lib/llvm/bin/clang++ -- a path that
	# does not exist under Gentoo's versioned layout, leaving hipcc unable to
	# find any compiler. Re-anchored on the component append, with an assert.
	# verified 2026-08-29 against therock-10.0.
	grep -qF 'hipClangPath /= "llvm";' src/hipBin_amd.h ||
		die "constructCompilerPath component-append anchor moved; hipcc would not find clang"
	if use amd-llvm; then
		# AMD's fork installs to /usr/lib/rocm-llvm/bin -- one directory, no
		# per-major slot -- so swap the component rather than inserting a slot.
		sed -e "s:hipClangPath /= \"llvm\";:hipClangPath /= \"rocm-llvm\";:" \
			-i src/hipBin_amd.h || die
	else
		sed -e "s:hipClangPath /= \"llvm\";:hipClangPath /= \"llvm\";\n  hipClangPath /= \"${LLVM_SLOT}\";:" \
			-i src/hipBin_amd.h || die
	fi

	# hipBin_amd.h carries no /opt/rocm reference at 10.0, and the single
	# occurrence left in hipBin_base.h is inside a --help string, not a path
	# constant -- so this is cosmetic now rather than load-bearing. Kept (the
	# help text should still say /usr) but narrowed to the file that actually
	# matches, so a future miss is visible. verified 2026-08-30.
	grep -q '/opt/rocm' src/hipBin_base.h ||
		die "/opt/rocm anchor moved in hipBin_base.h"
	sed -e "s:/opt/rocm:/usr:g" -i src/hipBin_base.h || die

	# Same class as the two seds above: a silent miss leaves hipcc probing
	# /usr/amdgcn/bitcode instead of /usr/lib/amdgcn/bitcode, so every device
	# compile fails to find the device libs.
	#
	# Unlike dev-libs/rocm-device-libs' OCL.cmake -- where an unanchored
	# global substitution also hit an already-correct occurrence and produced
	# lib/lib/amdgcn/bitcode -- hipBin_amd.h has exactly ONE occurrence
	# (:305 amdgcnBitcode /= "amdgcn/bitcode";) and no already-prefixed
	# "lib/amdgcn/bitcode", so the s///g cannot double-prefix here.
	# verified 2026-08-30 against the therock-10.0 source.
	grep -qF '"amdgcn/bitcode"' src/hipBin_amd.h ||
		die "amdgcn/bitcode anchor moved in hipBin_amd.h; hipcc would not find the device libs"
	sed -e "s:amdgcn/bitcode:lib/amdgcn/bitcode:g" \
		-i src/hipBin_amd.h || die
}

src_install() {
	cmake_src_install
	# remove bat files...
	rm -rf "${ED}/usr/hip" || die
}
