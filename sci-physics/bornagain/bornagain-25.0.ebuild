# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

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
IUSE="+python"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

# 25.0 removed its C++ data readers, so libtiff, zlib and bzip2 are gone, and
# no source includes Boost any more. The Python floors are upstream's
# install_requires; its fourth entry, vtk, is imported only inside
# showSample3D and stays optional here. verified 2026-10-09
DEPEND="
	sci-libs/fftw:3.0=
	sci-libs/gsl:=
	sci-libs/libcerf:=
	>=sci-libs/libformfactor-0.5.1 <sci-libs/libformfactor-0.6
	>=sci-libs/libheinz-4.1 <sci-libs/libheinz-5
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			>=dev-python/numpy-1.26.0[${PYTHON_USEDEP}]
		')
	)
"
RDEPEND="${DEPEND}
	python? (
		$(python_gen_cond_dep '
			>=dev-python/matplotlib-3.8.0[${PYTHON_USEDEP}]
			>=dev-python/packaging-22.0[${PYTHON_USEDEP}]
		')
	)
"
BDEPEND="virtual/pkgconfig"

# cerf must precede formfactor-config-fallback because both patch
# FindLibraries.cmake and the latter expects exact line numbers.
PATCHES=(
	"${FILESDIR}/${PN}-25.0-cerf-use-c-interface.patch"
	"${FILESDIR}/${PN}-25.0-formfactor-config-fallback.patch"
	"${FILESDIR}/${PN}-24.0-no-wheel-rpath.patch"
	"${FILESDIR}/${PN}-25.0-skip-wheel-py-deps-check.patch"
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	# Upstream accepts only Release or Debug.
	local CMAKE_BUILD_TYPE=Release

	# BA_PY_PACK builds the install tree without ba_wheel's packaging checks.
	local mycmakeargs=(
		-DBA_TESTS=OFF
		-DBA_DOCS=OFF
		-DBA_PY_PACK=$(usex python)
		-DBA_PYTHON=$(usex python)
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

		# Since 24.0, helpers and SWIG wrappers share the package root.
		insinto "${sitedir}/bornagain"
		doins "${py_pkg_dir}"/*.py

		# Symlink dual-purpose C++/Python libraries instead of duplicating ~14 MiB.
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
