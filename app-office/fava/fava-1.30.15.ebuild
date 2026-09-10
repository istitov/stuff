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

# Preserve beanquery's <0.3 BQL API bound; omit speculative caps elsewhere.
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
# The build hook compiles catalogs with Babel; hatch-vcs supplies the version.
BDEPEND="
	>=dev-python/babel-2.7[${PYTHON_USEDEP}]
	>=dev-python/hatch-vcs-0.4[${PYTHON_USEDEP}]
	>=dev-python/hatchling-1.27[${PYTHON_USEDEP}]
"

# The sdist lacks VCS metadata; provide the version to setuptools-scm.
export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"

# Use stock pytest; the complete suite runs only against an installed stack.
EPYTEST_PLUGINS=()

distutils_enable_tests pytest

python_prepare_all() {
	# Use the sdist's prebuilt frontend instead of invoking npm; keep Babel's
	# catalog compilation.
	grep -q '^    source_mtime = max(p\.stat' hatch_build.py ||
		die "frontend-build guard not found; re-audit hatch_build.py"
	sed -i \
		-e 's/^    source_mtime = max(p\.stat.*/    return  # frontend pre-built in sdist; do not invoke npm/' \
		hatch_build.py || die
	distutils-r1_python_prepare_all
}
