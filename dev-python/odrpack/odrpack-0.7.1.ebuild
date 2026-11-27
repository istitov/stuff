# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=meson-python
PYTHON_COMPAT=( python3_{12..14} )

# The Fortran is in sci-libs/odrpack95, but meson.build still declares the
# language, so configure needs a Fortran compiler.
inherit fortran-2 distutils-r1 pypi

# The nanobind meson subproject pinned by the sdist's nanobind.wrap.
NANOBIND_PV="2.15.0"
NANOBIND_WRAP="nanobind_${NANOBIND_PV}-1"

DESCRIPTION="Weighted orthogonal distance regression (ODR) for Python"
HOMEPAGE="
	https://github.com/HugoMVale/odrpack-python
	https://pypi.org/project/odrpack/
"
SRC_URI+="
	https://github.com/wjakob/nanobind/archive/refs/tags/v${NANOBIND_PV}.tar.gz
		-> nanobind-${NANOBIND_PV}.gh.tar.gz
	https://github.com/mesonbuild/wrapdb/releases/download/${NANOBIND_WRAP}/${NANOBIND_WRAP}_patch.zip
"

# The statically linked nanobind is BSD.
LICENSE="MIT BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	sci-libs/odrpack95:=
	>=dev-python/numpy-1.24[${PYTHON_USEDEP}]
"
# robin-map is header-only, used by the static nanobind.
DEPEND="
	${RDEPEND}
	dev-cpp/robin-map
"
BDEPEND="
	app-arch/unzip
	dev-build/cmake
	virtual/pkgconfig
	test? (
		dev-python/scipy[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_prepare() {
	# Put nanobind where its wrap expects it, so meson uses it instead of
	# downloading. odrpack95 and robin-map come from the system: drop their
	# wraps so a missing one fails the build rather than falling back.
	mv "${WORKDIR}/nanobind-${NANOBIND_PV}" subprojects/ || die
	rm subprojects/{odrpack95,robin-map}.wrap || die
	# Link the shared sci-libs/odrpack95, not the static subproject build.
	sed -i -e "s/dependency('odrpack95', static: true)/dependency('odrpack95')/" \
		meson.build || die
	grep -q "dependency('odrpack95')" meson.build || die "odrpack95 sed did not apply"

	# robin-map ships only a CMake config. Meson's plain lookup of it tries
	# pkg-config alone; naming the CMake target finds it. The wrapdb build
	# also strips nanobind consumers with -Wl,-s in release builds; leave
	# that to portage. verified 2026-11-27
	local nb="subprojects/nanobind-${NANOBIND_PV}/meson.build"
	sed -i \
		-e "s/^\(  'tsl-robin-map',\)$/\1\n  method: 'cmake',\n  modules: ['tsl::robin_map'],/" \
		-e "/dep_link_args += \['-Wl,-s'\]/d" \
		"${nb}" || die
	grep -q "tsl::robin_map" "${nb}" || die "robin-map sed did not apply"
	grep -q -- "-Wl,-s'" "${nb}" && die "strip sed did not apply"

	distutils-r1_src_prepare
}
