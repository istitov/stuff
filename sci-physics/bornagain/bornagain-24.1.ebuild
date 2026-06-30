# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit cmake python-single-r1

MY_P="${PN}-v${PV}"
DESCRIPTION="Simulate and fit X-ray/neutron reflectometry and grazing-incidence scattering"
HOMEPAGE="https://bornagainproject.org/
	https://jugit.fz-juelich.de/mlz/bornagain"
SRC_URI="https://jugit.fz-juelich.de/mlz/bornagain/-/archive/v${PV}/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+python +tiff"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

DEPEND="
	>=dev-libs/boost-1.74:=
	sci-libs/fftw:3.0=
	sci-libs/gsl:=
	sci-libs/libcerf:=
	>=sci-libs/libformfactor-0.4 <sci-libs/libformfactor-0.5
	>=sci-libs/libheinz-4.1 <sci-libs/libheinz-5
	virtual/zlib:=
	app-arch/bzip2:=
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-python/numpy[${PYTHON_USEDEP}]
		')
	)
	tiff? ( media-libs/tiff:= )
"
RDEPEND="${DEPEND}
	python? (
		$(python_gen_cond_dep '
			dev-python/matplotlib[${PYTHON_USEDEP}]
		')
	)
"
BDEPEND="virtual/pkgconfig"

# cerf must precede formfactor-config-fallback: both touch FindLibraries.cmake
# and applying cerf first (it's the lower hunk) keeps formfactor at its exact
# line numbers. The two qt6/deploy-bundling patches from 23.0 are dropped:
# 24.0 removed the GUI (Qt6 + the FixPack deploy step are both gone upstream).
PATCHES=(
	"${FILESDIR}/${PN}-24.0-cerf-use-c-interface.patch"
	"${FILESDIR}/${PN}-24.0-formfactor-config-fallback.patch"
	"${FILESDIR}/${PN}-24.0-no-wheel-rpath.patch"
	"${FILESDIR}/${PN}-24.0-skip-wheel-py-deps-check.patch"
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	# Upstream rejects any CMAKE_BUILD_TYPE other than Release or Debug
	# (cmake/BornAgain/CompilerInfo.cmake), so override the eclass default.
	local CMAKE_BUILD_TYPE=Release

	# BA_PY_PACK assembles the bornagain/ Python package tree in the build
	# dir (init + SWIG .py wrappers + POST_BUILD-copied .so files) — we
	# consume it directly from src_install. The ba_wheel custom target is
	# never invoked, so auditwheel / pip / wheel aren't actually needed
	# (covered by the skip-wheel-py-deps-check patch).
	local mycmakeargs=(
		-DBA_TESTS=OFF
		-DBA_DOCS=OFF
		-DBA_PY_PACK=$(usex python)
		-DBA_PYTHON=$(usex python)
		-DBA_TIFF_SUPPORT=$(usex tiff)
		-DCONFIGURE_BINDINGS=OFF
		-DZERO_TOLERANCE=OFF
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use python; then
		local sitedir
		sitedir=$(python_get_sitedir)
		local py_pkg_dir="${BUILD_DIR}/py/src/bornagain"

		[[ -d ${py_pkg_dir} ]] || die "Python package layout missing at ${py_pkg_dir}"

		# 24.0 flattened the package: __init__ + helpers (ba_plot, ba_check,
		# ...) and the SWIG-generated libBornAgain*.py wrappers all live
		# directly under py/src/bornagain (23.0 kept wrappers + .so in a lib/
		# subdir).
		insinto "${sitedir}/bornagain"
		doins "${py_pkg_dir}"/*.py

		# The _libBornAgain*.so files are dual-purpose — linkable C++ libs
		# in /usr/lib64/ and Python C extensions imported via the bornagain
		# package. Symlink rather than duplicate ~14 MiB of binaries.
		local sopath soname rel
		rel=$(realpath -m --relative-to="${sitedir}/bornagain" \
			"/usr/$(get_libdir)") || die "realpath failed"
		for sopath in "${py_pkg_dir}"/_libBornAgain*.so; do
			soname=${sopath##*/}
			dosym "${rel}/${soname}" "${sitedir}/bornagain/${soname}"
		done

		python_optimize "${ED}${sitedir}/bornagain"
	fi
}
