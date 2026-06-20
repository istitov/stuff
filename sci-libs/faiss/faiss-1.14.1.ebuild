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

		# libfaiss_python_callbacks.so is a pure-C++ helper (no
		# libpython link) that swigfaiss extensions DT_NEED. Upstream
		# PyPI wheels ship it inside the package dir and rely on
		# RPATH=$ORIGIN; Gentoo strips RPATH on install (cmake.eclass
		# QA cleanup), so move it to /usr/lib64 where ldconfig finds
		# it. verified 2026-05-09: SONAME has no libpython dep.
		local site
		site=$(python_get_sitedir)
		mv "${ED}${site}/faiss/libfaiss_python_callbacks.so" \
			"${ED}/usr/$(get_libdir)/" || die

		python_optimize
	fi
}
