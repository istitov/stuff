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
KEYWORDS="~amd64"
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

src_prepare() {
	# Upstream hardcodes -static-libgcc -static-libstdc++; strip them
	# so we produce a normal dynamically-linked library.
	sed -i \
		-e 's/-static-libgcc//g' \
		-e 's/-static-libstdc++//g' \
		CMakeLists.txt || die

	# -Ofast and -fno-finite-math-only are baked in. Let the user's
	# CFLAGS win; drop upstream's -Ofast (implies -ffast-math) since it
	# can be unsafe for scientific FP code.
	sed -i \
		-e 's/-Ofast//g' \
		-e 's/-ffast-math//g' \
		CMakeLists.txt || die

	# -mavx is hardcoded for UNIX. Gentoo users set their own -march,
	# so drop it; AVX will still be picked up via CFLAGS when
	# applicable.
	sed -i \
		-e 's/-mavx//g' \
		CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	# -Ofast pulls in -ffast-math, which can change FP results across
	# architectures; stay conservative.
	replace-flags '-Ofast' '-O3'
	append-flags -fno-finite-math-only

	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DGUI=OFF
		-DDLIB=OFF
		-DBUILD_PLOT_EXE=OFF
		-DCONSTEXPR_TABLES=OFF
		-DARCH=x86-64
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
