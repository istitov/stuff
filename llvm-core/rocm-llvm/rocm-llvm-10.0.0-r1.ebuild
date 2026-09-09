# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit check-reqs cmake flag-o-matic python-any-r1

# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); everything
# since is tagged therock-<major.minor>. This is the SAME source archive that
# dev-libs/rocm-device-libs, dev-libs/rocm-comgr and dev-util/hipcc already
# fetch -- they unpack the amd/ subdirectory, we unpack the compiler itself --
# so MY_P must stay byte-identical to theirs to share one DIST entry.
MY_P=llvm-project-therock-$(ver_cut 1-2)

DESCRIPTION="AMD's LLVM fork, as shipped with ROCm"
HOMEPAGE="https://github.com/ROCm/llvm-project"
SRC_URI="https://github.com/ROCm/llvm-project/archive/therock-$(ver_cut 1-2).tar.gz -> ${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}/llvm"

LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA BSD public-domain rc"
# Subslot tracks the ROCm release, matching the rest of the split stack: this
# compiler is only meaningful paired with the ROCm it shipped with.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"
IUSE="debug"

# The point of this package is to be a device-code compiler, so nothing here
# is a runtime dependency of anything except the ROCm build tooling.
RDEPEND="
	dev-libs/libxml2:=
	virtual/zlib:=
	app-arch/zstd:=
	dev-libs/rocm-device-libs:${SLOT}
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	app-alternatives/ninja
	dev-build/cmake
"

# ROCm's LLVM is a full compiler build. Scoped down hard in src_configure
# (two targets, three projects, no tests/docs/bindings), but it is still LLVM.
# Numbers measured on the first build; revisit if the project list grows.
CHECKREQS_DISK_BUILD="30G"

pkg_pretend() {
	[[ ${MERGE_TYPE} == binary ]] && return
	check-reqs_pkg_pretend
}

pkg_setup() {
	[[ ${MERGE_TYPE} == binary ]] && return
	check-reqs_pkg_setup
	python-any-r1_pkg_setup
}

src_unpack() {
	# The archive carries the whole llvm-project monorepo (~263 MB compressed,
	# every subproject including flang, mlir, lldb and libsycl). Extract only
	# what the compiler build reads: cmake/ for the shared modules, llvm/ as
	# S=, and the three projects enabled below. This turns a multi-GB unpack
	# into a fraction of it.
	#
	# Two of these are needed despite their PROJECT being disabled, both found
	# by build failure rather than inspection -- verified 2026-08-29:
	#   libc/   llvm's CMakeLists does an unconditional
	#           include(FindLibcCommonUtils) and FATAL_ERRORs without the
	#           header-only llvm-libc-common-utilities target from
	#           libc/src/__support.
	#   openmp/ AMD-fork-specific: clang/lib/CodeGen/CGEmitEmissaryExec.cpp
	#           hard-includes "../../openmp/device/include/EmissaryIds.h" for
	#           AMD's Emissary offload feature. Unconditional, so it is needed
	#           even with the openmp project off.
	#   libunwind/include/mach-o/
	#           lld builds its MachO backend unconditionally and takes
	#           <mach-o/compact_unwind_encoding.h> from libunwind's include
	#           tree (lld/MachO/CMakeLists.txt adds
	#           ${LLVM_MAIN_SRC_DIR}/../libunwind/include). ::gentoo's
	#           llvm-core/lld extracts exactly this path for the same reason.
	# The mlir/ and libunwind/ references under clang/ are ClangIR-only
	# (tools/cir-*, unittests/CIR) and stay unreachable while CLANG_ENABLE_CIR
	# is off, so the rest of libunwind is deliberately not extracted.
	local want=(
		"${MY_P}/cmake"
		"${MY_P}/llvm"
		"${MY_P}/clang"
		"${MY_P}/lld"
		"${MY_P}/libc"
		"${MY_P}/openmp"
		"${MY_P}/compiler-rt"
		"${MY_P}/libunwind/include/mach-o"
		"${MY_P}/runtimes"
		"${MY_P}/third-party"
	)
	ebegin "Unpacking the compiler subset from ${MY_P}.tar.gz"
	tar -x -z -o -f "${DISTDIR}/${MY_P}.tar.gz" "${want[@]}" || die
	eend ${?}
}

src_configure() {
	# LDFLAGS is filtered rather than dropped: -Wl,* is handed to the linker
	# verbatim by any driver and -L is only a search path, so both keep
	# their meaning across the compiler swap below, and clearing them
	# outright would cost the user's link-time hardening and any search
	# path they depend on. A whitelist on purpose -- the GCC-only hazards
	# in LDFLAGS are driver options (-flto-partition=none,
	# -fuse-linker-plugin), and anything not matched here is dropped
	# without having to be enumerated.
	local sub_ldflags= f
	for f in ${LDFLAGS}; do
		[[ ${f} == -Wl,* || ${f} == -L* ]] &&
			sub_ldflags+="${sub_ldflags:+ }${f}"
	done

	# One semicolon-separated string per sub-build: cmake reads it as a list
	# and passes each element to that sub-build's own cmake invocation.
	local sub_flags="-DCMAKE_C_FLAGS=;-DCMAKE_CXX_FLAGS=;-DCMAKE_ASM_FLAGS="
	sub_flags+=";-DCMAKE_EXE_LINKER_FLAGS=${sub_ldflags}"
	sub_flags+=";-DCMAKE_SHARED_LINKER_FLAGS=${sub_ldflags}"
	sub_flags+=";-DCMAKE_MODULE_LINKER_FLAGS=${sub_ldflags}"

	local mycmakeargs=(
		# AMD installs its compiler under <rocm>/lib/llvm. We deliberately do
		# NOT use /usr/lib/llvm/<n>, which is Gentoo's slot root for
		# llvm-core/llvm -- a private prefix is what keeps this package from
		# competing with the system LLVM at all.
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/lib/${PN}"

		# AMDGPU is the entire reason this package exists; X86 is needed for
		# the host side of any HIP compile.
		-DLLVM_TARGETS_TO_BUILD="AMDGPU;X86"
		-DLLVM_ENABLE_PROJECTS="clang;lld"
		# compiler-rt supplies libclang_rt.builtins, which clang links into
		# every HIP target; without it consumers fail at link time with
		# "libclang_rt.builtins.a ... missing and no known rule to make it".
		-DLLVM_ENABLE_RUNTIMES="compiler-rt"
		# compiler-rt is not built here: LLVM hands it to two nested
		# ExternalProjects (builtins and runtimes) that are configured
		# part-way through the build and compiled with the clang this
		# package has just produced, not with the compiler that built the
		# host side. Those nested cmake runs inherit our environment, and
		# cmake seeds CMAKE_<LANG>_FLAGS from CFLAGS / CXXFLAGS, and the
		# three CMAKE_*_LINKER_FLAGS from LDFLAGS, whenever the variable is
		# not set explicitly -- so a GCC-only flag in make.conf
		# (-fipa-pta, -fgraphite-identity, -flto-partition=none, ...) is
		# handed to clang, which rejects it and ends a build that has
		# already spent hours compiling the compiler itself. Passing the
		# variables here beats the environment and leaves the sub-builds on
		# cmake's own per-build-type defaults. The cost is that compiler-rt
		# is then compiled without any user CFLAGS/CXXFLAGS -- no user
		# optimisation, no -march. Only the linker side is preserved, and
		# only the portable part of it; see sub_ldflags above. Everything
		# else in this package is still built with the full set.
		# verified 2026-09-09, https://github.com/istitov/stuff/issues/282
		-DBUILTINS_CMAKE_ARGS="${sub_flags}"
		-DRUNTIMES_CMAKE_ARGS="${sub_flags}"

		# Match the system LLVM's packaging shape so consumers that resolve
		# components (e.g. llvm_map_components_to_libnames) get the dylib
		# rather than per-component archives.
		-DLLVM_BUILD_LLVM_DYLIB=ON
		-DLLVM_LINK_LLVM_DYLIB=ON
		# LLVM refuses BUILD_SHARED_LIBS together with LLVM_LINK_LLVM_DYLIB
		# ("we recommend disabling BUILD_SHARED_LIBS"); the two are different
		# strategies for the same goal. The single libLLVM.so is the one we
		# want, matching how llvm-core/llvm is built.
		-DBUILD_SHARED_LIBS=OFF

		-DLLVM_ENABLE_ZLIB=FORCE_ON
		-DLLVM_ENABLE_ZSTD=FORCE_ON
		-DLLVM_ENABLE_LIBXML2=FORCE_ON
		# Detected automagically otherwise, putting an undeclared
		# DT_NEEDED on libedit.so.0 into libLLVM. Nothing here is used
		# interactively -- this compiler exists to be driven by
		# rocm_use_clang() -- so turn it off rather than take the
		# dependency. verified 2026-08-30 by readelf on libLLVM.so.
		-DLLVM_ENABLE_LIBEDIT=OFF

		# Nothing here is consumed; skip it all to keep the build bounded.
		-DLLVM_BUILD_TESTS=OFF
		-DLLVM_INCLUDE_TESTS=OFF
		-DLLVM_INCLUDE_BENCHMARKS=OFF
		-DLLVM_INCLUDE_EXAMPLES=OFF
		-DLLVM_ENABLE_OCAMLDOC=OFF
		-DLLVM_ENABLE_BINDINGS=OFF
		-DLLVM_INSTALL_UTILS=OFF

		# Explicit, like llvm-core/llvm. Necessary but NOT sufficient on its
		# own -- see the append-cflags below.
		-DLLVM_ENABLE_ASSERTIONS=$(usex debug)

		-DPython3_EXECUTABLE="${PYTHON}"
		-Wno-dev
	)

	if ! use debug; then
		# LLVM_ENABLE_ASSERTIONS=no only stops LLVM from UN-defining NDEBUG;
		# it counts on CMake's own CMAKE_CXX_FLAGS_RELEASE to DEFINE it. But
		# cmake.eclass blanks the per-config flag variables so they cannot
		# override user CXXFLAGS, so nothing defines NDEBUG and every assert()
		# in LLVM stays live -- `clang-23 --version` then reports
		# "Build config: +assertions" despite the option being off.
		#
		# That is not cosmetic. sci-ml/caffe2 aborts building rocPRIM's
		# merge-sort kernels for gfx1150:
		#
		#   clang-23: llvm/lib/CodeGen/LiveRegUnits.cpp:45:
		#     void llvm::LiveRegUnits::stepBackward(...): Assertion failed
		#   ... Running pass 'SI optimize exec mask operations'
		#
		# As with sci-libs/hipBLASLt and sci-libs/composable-kernel, this
		# aligns the build config with AMD's shipped Release compiler; it does
		# not address why that invariant is violated in the first place. AMD's
		# own binaries take the same code path without aborting. If ROCm ever
		# produces visibly wrong kernels, revisit this rather than assume the
		# codegen is sound. verified 2026-08-30.
		append-cflags "-DNDEBUG"
		append-cxxflags "-DNDEBUG"

		# Set through the eclass variable, not -DCMAKE_BUILD_TYPE: the
		# eclass appends its own after mycmakeargs, so a -D here loses and
		# the build silently stays RelWithDebInfo. It makes no difference
		# to this build's own flags -- the eclass blanks the per-config
		# variables for whichever type is active -- but the two compiler-rt
		# sub-builds above are handed ${CMAKE_BUILD_TYPE} and are not
		# eclass-managed, so this is what moves their per-config default
		# from -O2 -g -DNDEBUG to -O3 -DNDEBUG. compiler-rt still layers
		# its own per-target flags on top. verified 2026-09-09
		CMAKE_BUILD_TYPE=Release
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# rocm.eclass's rocm_use_clang() does
	#     export CC="${hipclangpath}/${CHOST}-clang"
	#     export CXX="${hipclangpath}/${CHOST}-clang++"
	# i.e. it expects Gentoo's CHOST-prefixed wrapper names, which
	# llvm-core/clang provides as symlinks. AMD's build installs only the
	# unprefixed clang/clang++ (plus its own amdclang* aliases), so without
	# these every ROCm library configured through rocm_use_clang fails with
	# "CMAKE_CXX_COMPILER ... is not a full path to an existing compiler tool".
	# Mirror llvm-core/clang's layout. verified 2026-08-29.
	local t
	for t in clang clang++; do
		[[ -e ${ED}/usr/lib/${PN}/bin/${t} ]] ||
			die "AMD LLVM did not install bin/${t}; wrapper names need re-checking"
		dosym "${t}" "/usr/lib/${PN}/bin/${CHOST}-${t}"
	done

	# Let this clang find dev-libs/rocm-device-libs. Clang looks for the ROCm
	# device bitcode under <its resource dir>/lib/amdgcn/bitcode;
	# rocm-device-libs installs the real files to /usr/lib/amdgcn/bitcode and
	# symlinks them into the SYSTEM clang's resource dir only, so AMD's clang
	# otherwise fails every HIP compile with "cannot find ROCm device
	# library".
	#
	# Note the subdirectory differs by build: Gentoo's llvm sets
	# LLVM_LIBDIR_SUFFIX so its resource dir uses lib64/amdgcn, while this
	# build uses the default and wants lib/amdgcn. Glob the version component
	# rather than hardcoding the clang major. verified 2026-08-29.
	local rd found=
	for rd in "${ED}"/usr/lib/${PN}/lib/clang/*; do
		[[ -d ${rd} ]] || continue
		dosym -r /usr/lib/amdgcn "${rd#"${ED}"}/lib/amdgcn"
		found=1
	done
	[[ -n ${found} ]] ||
		die "no clang resource dir under /usr/lib/${PN}/lib/clang; device-lib symlink not placed"

	# No env.d and no symlinks into /usr/bin. This compiler must be reachable
	# only when something asks for it explicitly -- shadowing the system
	# clang would be a much worse outcome than the problem it solves. The
	# consumer-side hook is dev-util/hipcc[amd-llvm], which makes
	# `hipconfig --hipclangpath` report the path below; rocm.eclass's
	# rocm_use_clang() then routes every ROCm library build through it.
	# clang's scan-build ships a man page into the shared /usr/share/man,
	# which breaks the "everything stays in the private prefix" property and
	# advertises a tool that is deliberately not in PATH. Drop it.
	rm -rf "${ED}/usr/share/man" || die

	elog "AMD's LLVM is installed to ${EPREFIX}/usr/lib/${PN}"
	elog
	elog "It is deliberately NOT in PATH and does not shadow llvm-core/clang."
	elog "To build the ROCm math libraries with it, enable USE=amd-llvm on"
	elog "dev-util/hipcc; rocm.eclass picks it up automatically from"
	elog "\`hipconfig --hipclangpath\`."
}
