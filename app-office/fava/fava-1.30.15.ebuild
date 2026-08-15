# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Web interface for the Beancount plain-text accounting system"
HOMEPAGE="
	https://beancount.github.io/fava/
	https://github.com/beancount/fava
	https://pypi.org/project/fava/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# beanquery is capped tight (<0.3): fava couples to its BQL API surface
# and upstream tracks it minor-by-minor. The remaining deps carry only
# their lower bounds — upstream's speculative next-major caps are not
# mirrored.
RDEPEND="
	>=app-office/beancount-3.2.0[${PYTHON_USEDEP}]
	>=dev-python/babel-2.11[${PYTHON_USEDEP}]
	>=dev-python/beangulp-0.2[${PYTHON_USEDEP}]
	>=dev-python/beanquery-0.1[${PYTHON_USEDEP}]
	<dev-python/beanquery-0.3[${PYTHON_USEDEP}]
	>=dev-python/cheroot-8[${PYTHON_USEDEP}]
	dev-python/click[${PYTHON_USEDEP}]
	>=dev-python/flask-2.2[${PYTHON_USEDEP}]
	>=dev-python/flask-babel-3[${PYTHON_USEDEP}]
	>=dev-python/jinja2-3[${PYTHON_USEDEP}]
	>=dev-python/markdown-it-py-3[${PYTHON_USEDEP}]
	>=dev-python/ply-3.4[${PYTHON_USEDEP}]
	>=dev-python/simplejson-3.16.0[${PYTHON_USEDEP}]
	>=dev-python/watchfiles-0.20.0[${PYTHON_USEDEP}]
	>=dev-python/werkzeug-2.2[${PYTHON_USEDEP}]
"
# The custom Hatchling build hook imports Babel to compile the .po catalogues
# and hatch-vcs obtains the version through setuptools-scm. Upstream's Babel
# <3 cap is not mirrored because 2.18.0 is the only version in tree.
BDEPEND="
	>=dev-python/babel-2.7[${PYTHON_USEDEP}]
	>=dev-python/hatch-vcs-0.4[${PYTHON_USEDEP}]
	>=dev-python/hatchling-1.27[${PYTHON_USEDEP}]
"

# setuptools_scm has no VCS in the unpacked sdist; feed it the version.
export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"

# Stock pytest only (the test suite is gated on the full chain being
# installed; not run at package time).
EPYTEST_PLUGINS=()

distutils_enable_tests pytest

python_prepare_all() {
	# The frontend bundle (src/fava/static/*.js) and .mo catalogues ship
	# pre-built in the sdist. hatch_build._compile_frontend() would
	# otherwise shell out to npm to rebuild them; neutralise it so the
	# bundled assets are used and no Node toolchain is needed. The .mo
	# compilation step is left intact (pure Babel, a build dep).
	grep -q '^    source_mtime = max(p\.stat' hatch_build.py ||
		die "frontend-build guard not found; re-audit hatch_build.py"
	sed -i \
		-e 's/^    source_mtime = max(p\.stat.*/    return  # frontend pre-built in sdist; do not invoke npm/' \
		hatch_build.py || die
	distutils-r1_python_prepare_all
}
