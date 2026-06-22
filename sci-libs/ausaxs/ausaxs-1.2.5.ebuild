# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic

DESCRIPTION="Efficient small-angle X-ray scattering (SAXS) fitting and analysis"
HOMEPAGE="https://github.com/AUSAXS/AUSAXS"
SRC_URI="https://github.com/AUSAXS/AUSAXS/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/AUSAXS-${PV}"

LICENSE="LGPL-3+"
SLOT="0/1.2"
KEYWORDS="~amd64 ~arm64"
IUSE="doc executables"

# dlib FetchContent path is always taken when DLIB=ON (there is no
# USE_SYSTEM_DLIB toggle upstream), which would require network access
# during build. The Python bindings SasView cares about only use the
# SANS Debye calculator which does not need the dlib minimizers, so we
# disable DLIB entirely rather than vendoring dlib.
#
# Coexists with dev-python/pyausaxs.  pyausaxs bundles its own prebuilt
# libausaxs.so inside the wheel and loads it via ctypes.CDLL with an
# absolute path (pkg_resources.files("pyausaxs").joinpath(
# "resources/libausaxs.so")) — that path doesn't go through ldconfig,
# so our /usr/lib64/libausaxs.so is invisible at runtime even though
# both files share the libausaxs.so SONAME.  Empirically verified
# 2026-05-16: with both libraries on disk, pyausaxs's six ctypes-wired
# symbols still resolve from the bundled .so and the system .so's
# `debye_no_ff` (which the bundled copy doesn't export) is absent in
# the loaded image.  Symbol sets remain divergent — the from-source
# 1.2.3 ABI exposes ~44 C symbols (cli_*, molecule_*, pdb_*, fit_*,
# iterative_fit_init/evaluate, …) while pyausaxs's bundled copy
# exposes exactly the 6 SasView calls.  This ebuild is useful on its
# own for the saxs_fitter / em_fitter / rigidbody_optimizer CLI tools
# and for direct C/C++ consumers.
RDEPEND="
	net-misc/curl
	dev-cpp/gcem
	dev-cpp/backward-cpp
	dev-cpp/cli11
	dev-cpp/bshoshany-thread-pool
"
DEPEND="${RDEPEND}"
BDEPEND="doc? ( app-text/doxygen )"

# 1.2.5's new symmetry code has a malformed move-ctor assert lambda that
# only compiles under upstream's NDEBUG Release; fix it for our
# assert-live build. verified 2026-06-22
PATCHES=( "${FILESDIR}/${P}-symmetry-storage-assert-lambda.patch" )

src_prepare() {
	# Upstream hardcodes -static-libgcc -static-libstdc++; strip them
	# so we produce a normal dynamically-linked library.
	sed -i \
		-e 's/-static-libgcc//g' \
		-e 's/-static-libstdc++//g' \
		CMakeLists.txt || die

	# 1.2.4 relocated the optimisation flags out of CMakeLists.txt into
	# cmake/setup_compile_commands.cmake. Upstream bakes in -ffast-math
	# (now -O3-based, no longer -Ofast); strip it since fast-math changes
	# FP results and is unsafe for scientific code. -mavx is gone too —
	# -march is now driven by the ARCH cache var (set to x86-64 below),
	# so no separate AVX strip is needed. verified 2026-06-10
	sed -i \
		-e 's/-ffast-math//g' \
		cmake/setup_compile_commands.cmake || die

	# Drop the tests subdirectory: it is EXCLUDE_FROM_ALL and we never
	# build it (no test IUSE, src_compile builds only the lib + CLI
	# targets), but its unconditional find_package(Catch2 REQUIRED) under
	# USE_SYSTEM_CATCH=ON would pull in an otherwise-undeclared Catch2
	# build dep at configure time. Removing it keeps the ebuild
	# self-contained. verified 2026-06-10
	sed -i \
		-e '/^add_subdirectory(tests)/d' \
		CMakeLists.txt || die

	# Strip the per-executable POST_BUILD plotting-script copy. All four
	# executables share one output dir (bin/) and each attaches a
	# non-atomic copy_if_different of scripts/plot{,_helper}.py to it;
	# under parallel make they race on the same destination and fail
	# intermittently ("No such file or directory"). We do not install
	# these helper scripts anyway, so drop the invocations outright.
	# verified 2026-06-10
	sed -i \
		-e '/^add_plot_scripts_to_target(/d' \
		executable/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	# Keep finite-math assumptions off; upstream pairs -ffast-math (which
	# we strip in src_prepare) with -fno-finite-math-only, so retain the
	# latter explicitly to stay conservative on scientific FP.
	append-flags -fno-finite-math-only

	# CONSTEXPR_TABLES was dropped upstream in 1.2.4. ARCH keys into
	# cmake/setup_compile_commands.cmake's MARCH_FLAGS: amd64/x86 take a
	# generic -march=x86-64 baseline (no illegal instructions on old CPUs);
	# arm64 takes -march=armv8-a. Upstream's bare "x86-64" is invalid on
	# aarch64 (g++ rejects -march=x86-64), so select per-arch.
	local march
	case ${ARCH} in
		amd64|x86) march="x86-64" ;;
		arm64)     march="armv8-a" ;;
		*)         march="auto" ;;
	esac
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DGUI=OFF
		-DDLIB=OFF
		-DBUILD_PLOT_EXE=OFF
		-DARCH="${march}"
		-DUSE_SYSTEM_GCEM=ON
		-DUSE_SYSTEM_BACKWARD=ON
		-DUSE_SYSTEM_CLI11=ON
		-DUSE_SYSTEM_THREADPOOL=ON
		-DUSE_SYSTEM_CATCH=ON
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
	)
	cmake_src_configure
}

src_compile() {
	# libausaxs builds the SHARED libausaxs.so consumed by pyausaxs's ctypes
	# bindings.  1.2.2 implicitly built it as a transitive target of `ausaxs`;
	# 1.2.3 restructured the cmake graph so it has to be requested
	# explicitly.
	local targets=( ausaxs libausaxs )
	use executables && targets+=( saxs_fitter em_fitter rigidbody_optimizer )
	cmake_src_compile "${targets[@]}"

	if use doc; then
		cmake_src_compile doc
	fi
}

src_install() {
	# Upstream does not define any install() targets; copy artifacts
	# manually from the build tree.
	dolib.so "${BUILD_DIR}/lib/libausaxs.so"

	if use executables; then
		dobin "${BUILD_DIR}/bin/saxs_fitter"
		dobin "${BUILD_DIR}/bin/em_fitter"
		dobin "${BUILD_DIR}/bin/rigidbody_optimizer"
	fi

	# Public API headers — small enough to bundle for future C/C++
	# consumers, even though our immediate use is via pyausaxs ctypes.
	insinto /usr/include/ausaxs
	doins -r include/api/.
	doins -r include/core/.

	if use doc; then
		HTML_DOCS=( "${BUILD_DIR}/html/." )
	fi
	einstalldocs
}
