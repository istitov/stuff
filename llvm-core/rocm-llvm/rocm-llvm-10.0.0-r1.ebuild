# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit check-reqs cmake flag-o-matic python-any-r1 toolchain-funcs

# ROCm now uses therock-<major.minor> tags. Keep this archive name identical to
# rocm-device-libs, rocm-comgr, and hipcc so Portage shares one distfile.
MY_P=llvm-project-therock-$(ver_cut 1-2)

DESCRIPTION="AMD's LLVM fork, as shipped with ROCm"
HOMEPAGE="https://github.com/ROCm/llvm-project"
SRC_URI="https://github.com/ROCm/llvm-project/archive/therock-$(ver_cut 1-2).tar.gz -> ${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}/llvm"

LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA BSD public-domain rc"
# This compiler must match the ROCm release that shipped it.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"
IUSE="debug"

RDEPEND="
	dev-libs/libxml2:=
	virtual/zlib:=
	app-arch/zstd:=
	dev-libs/rocm-device-libs:${SLOT}
"
# Only plugin-api.h is needed to build LLVMgold; ld loads the result at runtime.
DEPEND="${RDEPEND}
	sys-libs/binutils-libs
"
BDEPEND="
	${PYTHON_DEPS}
	app-alternatives/ninja
	dev-build/cmake
"

# Measured with the restricted project set below; revisit if it grows.
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
	# Extract only the compiler inputs. libc supplies an unconditional common
	# utilities target; AMD clang directly includes openmp's EmissaryIds.h; and
	# lld's always-built MachO backend needs libunwind's compact-unwind header.
	# ClangIR-only mlir and the rest of libunwind remain unnecessary.
	# verified 2026-08-29
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
	# Match ::gentoo's GCC-only LTO filter for LLVM ODR/miscompile risks.
	# (bugs #917536 and #926529; adopted 2026-09-09).
	tc-is-gcc && filter-lto

	# Match ::gentoo's workaround for upstream issue #219693; adopted 2026-09-09.
	append-flags -fno-strict-aliasing

	# Nested Clang builds may reject GCC driver flags. Retain only portable
	# linker arguments and search paths, including user hardening.
	local sub_ldflags= f
	for f in ${LDFLAGS}; do
		[[ ${f} == -Wl,* || ${f} == -L* ]] &&
			sub_ldflags+="${sub_ldflags:+ }${f}"
	done

	# CMake forwards this semicolon-separated list to each nested build.
	local sub_flags="-DCMAKE_C_FLAGS=;-DCMAKE_CXX_FLAGS=;-DCMAKE_ASM_FLAGS="
	sub_flags+=";-DCMAKE_EXE_LINKER_FLAGS=${sub_ldflags}"
	sub_flags+=";-DCMAKE_SHARED_LINKER_FLAGS=${sub_ldflags}"
	sub_flags+=";-DCMAKE_MODULE_LINKER_FLAGS=${sub_ldflags}"

	local mycmakeargs=(
		# A private prefix prevents conflicts with Gentoo's slotted LLVM.
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/lib/${PN}"

		# HIP needs AMDGPU device code and an X86 host compiler.
		-DLLVM_TARGETS_TO_BUILD="AMDGPU;X86"
		-DLLVM_ENABLE_PROJECTS="clang;lld"
		# HIP links libclang_rt.builtins into every target.
		-DLLVM_ENABLE_RUNTIMES="compiler-rt"
		# LLVM builds compiler-rt with its newly built Clang. Clear inherited
		# CFLAGS/CXXFLAGS so GCC-only flags cannot break these late nested builds;
		# preserve only the portable LDFLAGS selected above.
		# verified 2026-09-09, https://github.com/istitov/stuff/issues/282
		-DBUILTINS_CMAKE_ARGS="${sub_flags}"
		-DRUNTIMES_CMAKE_ARGS="${sub_flags}"

		# GNU ld is the default, so Clang requires its private LLVMgold.so for
		# -flto compiler tests. Build it unconditionally, but do not register it
		# system-wide through llvmgold; this compiler must remain isolated.
		# https://github.com/istitov/stuff/issues/284
		-DLLVM_BINUTILS_INCDIR="${ESYSROOT}"/usr/include

		# Match system LLVM so component resolution selects the dylib.
		-DLLVM_BUILD_LLVM_DYLIB=ON
		-DLLVM_LINK_LLVM_DYLIB=ON
		# Use one libLLVM.so, not per-component shared libraries.
		-DBUILD_SHARED_LIBS=OFF

		-DLLVM_ENABLE_ZLIB=FORCE_ON
		-DLLVM_ENABLE_ZSTD=FORCE_ON
		-DLLVM_ENABLE_LIBXML2=FORCE_ON
		# Avoid an automagic libedit DT_NEEDED; this compiler is non-interactive.
		# verified 2026-08-30 with readelf
		-DLLVM_ENABLE_LIBEDIT=OFF

		-DLLVM_BUILD_TESTS=OFF
		-DLLVM_INCLUDE_TESTS=OFF
		-DLLVM_INCLUDE_BENCHMARKS=OFF
		-DLLVM_INCLUDE_EXAMPLES=OFF
		-DLLVM_ENABLE_OCAMLDOC=OFF
		-DLLVM_ENABLE_BINDINGS=OFF
		-DLLVM_INSTALL_UTILS=OFF

		# NDEBUG still needs explicit handling below.
		-DLLVM_ENABLE_ASSERTIONS=$(usex debug)
		# Trap on violated llvm_unreachable() assumptions instead of invoking UB;
		# matches ::gentoo's llvm-23. adopted 2026-09-09
		-DLLVM_UNREACHABLE_OPTIMIZE=OFF

		-DPython3_EXECUTABLE="${PYTHON}"
		-Wno-dev
	)

	if ! use debug; then
		# cmake.eclass clears release flags, so LLVM_ENABLE_ASSERTIONS=OFF alone
		# leaves assertions active. They abort gfx1150 rocPRIM codegen; match AMD's
		# Release compiler, but revisit if kernels miscompile. verified 2026-08-30
		append-cflags "-DNDEBUG"
		append-cxxflags "-DNDEBUG"

		# Set the eclass variable because its later argument wins. This selects
		# Release defaults for the unmanaged compiler-rt sub-builds.
		# verified 2026-09-09
		CMAKE_BUILD_TYPE=Release
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# rocm_use_clang expects Gentoo's CHOST-prefixed names; AMD installs only
	# unprefixed drivers. Mirror llvm-core/clang's layout. verified 2026-08-29
	local t
	for t in clang clang++; do
		[[ -e ${ED}/usr/lib/${PN}/bin/${t} ]] ||
			die "AMD LLVM did not install bin/${t}; wrapper names need re-checking"
		dosym "${t}" "/usr/lib/${PN}/bin/${CHOST}-${t}"
	done

	# Link the system ROCm bitcode into this Clang's private resource directory.
	# Its layout uses lib rather than system LLVM's lib64; glob the Clang major.
	# verified 2026-08-29
	local rd found=
	for rd in "${ED}"/usr/lib/${PN}/lib/clang/*; do
		[[ -d ${rd} ]] || continue
		dosym -r /usr/lib/amdgcn "${rd#"${ED}"}/lib/amdgcn"
		found=1
	done
	[[ -n ${found} ]] ||
		die "no clang resource dir under /usr/lib/${PN}/lib/clang; device-lib symlink not placed"

	# Keep this compiler out of PATH and shared locations. hipcc[amd-llvm]
	# exposes it through hipconfig; remove scan-build's shared man page.
	rm -rf "${ED}/usr/share/man" || die

	elog "AMD's LLVM is installed to ${EPREFIX}/usr/lib/${PN}"
	elog
	elog "It is deliberately NOT in PATH and does not shadow llvm-core/clang."
	elog "To build the ROCm math libraries with it, enable USE=amd-llvm on"
	elog "dev-util/hipcc; rocm.eclass picks it up automatically from"
	elog "\`hipconfig --hipclangpath\`."
}
