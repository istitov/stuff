# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 optfeature pypi

DESCRIPTION="Python wrapper around the AUSAXS C++ SAXS library"
HOMEPAGE="
	https://github.com/AUSAXS/pyAUSAXS
	https://pypi.org/project/pyausaxs/
"

LICENSE="LGPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	~sci-libs/ausaxs-${PV}
	>=dev-python/py-cpuinfo-8.0.0[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.20.0[${PYTHON_USEDEP}]
"

src_prepare() {
	distutils-r1_src_prepare

	# Source releases have no bundled backend; use Gentoo's multilib path.
	sed -i -e \
		"s|Path(sys.prefix) / \"lib\" / (\"libausaxs\" + ext)|Path(\"${EPREFIX}/usr/$(get_libdir)/libausaxs\" + ext)|" \
		pyausaxs/loader.py || die "libdir sed failed"
}

EPYTEST_PLUGINS=()
EPYTEST_IGNORE=(
	# The sdist omits tests/helpers.py and tests/files/.
	tests/test_fit.py
	tests/test_histogram_debye.py
	tests/test_io.py
	tests/test_misc.py
	tests/test_molecule.py
)
distutils_enable_tests pytest

pkg_postinst() {
	optfeature "plotting fit results" ">=dev-python/matplotlib-3.7"
	optfeature "curve-fit helpers in the plotting module" ">=dev-python/scipy-1.10"
}
