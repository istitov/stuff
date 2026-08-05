# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit cmake python-single-r1

DESCRIPTION="Library for efficient similarity search and clustering of dense vectors"
HOMEPAGE="
	https://github.com/facebookresearch/faiss
	https://faiss.ai
"
SRC_URI="https://github.com/facebookresearch/faiss/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64"
IUSE="python test
	cpu_flags_x86_avx2 cpu_flags_x86_avx512f"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RESTRICT="!test? ( test )"

# OpenMP comes from gcc; no separate dep.
RDEPEND="
	virtual/blas
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-python/numpy[${PYTHON_USEDEP}]
		')
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	python? (
		dev-lang/swig
		$(python_gen_cond_dep '
			dev-python/pip[${PYTHON_USEDEP}]
			dev-python/setuptools[${PYTHON_USEDEP}]
		')
	)
"

# The AVX512 fast-scan headers gate their use of the AVX512 simd types on
# bare __AVX512F__, but those types are only defined when COMPILE_SIMD_AVX512
# is also set (the faiss_avx512 target). A -march that enables AVX512 (e.g.
# znver5) thus breaks the generic/avx2 targets on gcc-16. verified 2026-06-13
PATCHES=( "${FILESDIR}"/faiss-1.14.2-avx512-fast-scan-compile-guard.patch )

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	# FAISS_OPT_LEVEL is hierarchical: avx512 ⊇ avx2 ⊇ generic. The
	# Python loader picks the highest variant available at runtime.
	local opt_level="generic"
	use cpu_flags_x86_avx2 && opt_level="avx2"
	use cpu_flags_x86_avx512f && opt_level="avx512"

	local mycmakeargs=(
		-DFAISS_ENABLE_GPU=OFF
		-DFAISS_ENABLE_PYTHON=$(usex python)
		-DFAISS_ENABLE_C_API=ON
		-DFAISS_ENABLE_CUVS=OFF
		-DFAISS_ENABLE_ROCM=OFF
		-DFAISS_ENABLE_SVS=OFF
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_TESTING=$(usex test)
		-DCMAKE_BUILD_TYPE=Release
		-DFAISS_OPT_LEVEL="${opt_level}"
	)
	use python && mycmakeargs+=( -DPython_EXECUTABLE="${PYTHON}" )

	cmake_src_configure
}

src_compile() {
	cmake_src_compile faiss
	use cpu_flags_x86_avx2 && cmake_src_compile faiss_avx2
	use cpu_flags_x86_avx512f && cmake_src_compile faiss_avx512

	if use python; then
		cmake_src_compile swigfaiss
		use cpu_flags_x86_avx2 && cmake_src_compile swigfaiss_avx2
		use cpu_flags_x86_avx512f && cmake_src_compile swigfaiss_avx512
	fi
}

src_install() {
	cmake_src_install

	if use python; then
		# CMake populates BUILD_DIR/faiss/python with setup.py + the
		# compiled _swigfaiss*.so artifacts; setup.py only packages
		# the existing files (no compilation step).
		cd "${BUILD_DIR}/faiss/python" || die
		"${PYTHON}" -m pip install \
			--root="${D}" \
			--prefix="${EPREFIX}/usr" \
			--no-deps \
			--no-build-isolation \
			--no-compile \
			--ignore-installed \
			--disable-pip-version-check \
			--no-warn-script-location \
			. || die "pip install failed"

		# faiss's python CMake also installs the package (plus a second
		# copy of libfaiss*.so, ~57M) to ${EPREFIX}/usr/faiss; the
		# importable package is the pip-installed site-packages copy
		# above, so drop the redundant CMake copy. verified 2026-06-13
		rm -r "${ED}/usr/faiss" || die

		# faiss builds libfaiss_python_callbacks as a STATIC lib
		# (faiss/python/CMakeLists.txt) and links it into each
		# _swigfaiss*.so, so there is no standalone .so in the package dir
		# to relocate; the modules only DT_NEED libfaiss.so, found via
		# ldconfig. Earlier faiss shipped it as a shared .so, which the
		# ebuild moved to /usr/lib64 — obsolete (and the move would fail,
		# the file no longer exists). verified 2026-06-13.

		python_optimize
	fi
}
