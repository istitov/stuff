# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 optfeature pypi

DESCRIPTION="Statistical and interactive HTML plots for Python"
HOMEPAGE="https://bokeh.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=dev-python/jinja2-2.9[${PYTHON_USEDEP}]
	>=dev-python/contourpy-1.2[${PYTHON_USEDEP}]
	>=dev-python/narwhals-1.13[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.16[${PYTHON_USEDEP}]
	>=dev-python/packaging-16.8[${PYTHON_USEDEP}]
	>=dev-python/pillow-7.1.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-3.10[${PYTHON_USEDEP}]
	>=dev-python/tornado-6.2[${PYTHON_USEDEP}]
	>=dev-python/xyzservices-2021.09.1[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/beautifulsoup4[${PYTHON_USEDEP}]
		dev-python/flaky[${PYTHON_USEDEP}]
		dev-python/ipython-genutils[${PYTHON_USEDEP}]
		dev-python/mock[${PYTHON_USEDEP}]
		dev-python/networkx[${PYTHON_USEDEP}]
		dev-python/nbconvert[${PYTHON_USEDEP}]
		dev-python/nbformat[${PYTHON_USEDEP}]
		dev-python/pydot[${PYTHON_USEDEP}]
		dev-python/pytz[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/selenium[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_prepare() {
	# sdist has no git info; pin dynamic version to PV so the dist-info
	# directory is named correctly instead of bokeh-0.0.0.
	sed -i -e "/^dynamic = /d" \
		-e "/^\[project\]$/a version = \"${PV}\"" \
		-e "/^\[tool\.setuptools-git-versioning\]/,/^\[/{/^\[tool\.setuptools-git-versioning\]/d; /^\[/!d}" \
		pyproject.toml || die
	distutils-r1_src_prepare
}

python_test() {
	# disable tests having network calls
	local SKIP_TESTS=" \
		not (test___init__ and TestWarnings and test_filters) and \
		not (test_json__subcommands and test_no_script) and \
		not (test_standalone and Test_autoload_static) and \
		not test_nodejs_compile_javascript and \
		not test_nodejs_compile_less and \
		not test_inline_extension and \
		not (test_model and test_select) and \
		not test_tornado__server and \
		not test_client_server and \
		not test_webdriver and \
		not test_export and \
		not test_server and \
		not test_bundle and \
		not test_ext and \
		not test_detect_current_filename \
	"
	epytest -m "not sampledata" tests/unit -k "${SKIP_TESTS}"
}

pkg_postinst() {
	optfeature "integration with amazon S3" dev-python/boto
	optfeature "pypi integration to publish packages" dev-python/twine
	optfeature "js library usage" net-libs/nodejs
}
