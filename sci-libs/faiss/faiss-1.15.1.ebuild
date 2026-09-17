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
			dev-python/packaging[${PYTHON_USEDEP}]
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

# AVX512 types require COMPILE_SIMD_AVX512, but upstream gates them only on
# __AVX512F__; AVX512 -march otherwise breaks generic/avx2. # verified 2026-06-13
PATCHES=( "${FILESDIR}"/faiss-1.14.2-avx512-fast-scan-compile-guard.patch )

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	# Build hierarchical variants; Python selects the highest available at runtime.
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
		# CMake produces setup.py and compiled modules; pip only packages them.
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

		# Drop CMake's redundant /usr/faiss copy; site-packages is authoritative.
		# verified 2026-06-13
		rm -r "${ED}/usr/faiss" || die

		python_optimize
	fi
}
