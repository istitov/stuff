# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Project documentation with Markdown"
HOMEPAGE="
	https://www.mkdocs.org/
	https://github.com/mkdocs/mkdocs
	https://pypi.org/project/mkdocs/
"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="i18n"

RDEPEND="
	>=dev-python/click-7.0[${PYTHON_USEDEP}]
	>=dev-python/ghp-import-1.0[${PYTHON_USEDEP}]
	>=dev-python/jinja2-2.11.1[${PYTHON_USEDEP}]
	>=dev-python/markdown-3.3.6[${PYTHON_USEDEP}]
	>=dev-python/markupsafe-2.0.1[${PYTHON_USEDEP}]
	>=dev-python/mergedeep-1.3.4[${PYTHON_USEDEP}]
	>=dev-python/mkdocs-get-deps-0.2.0[${PYTHON_USEDEP}]
	>=dev-python/packaging-20.5[${PYTHON_USEDEP}]
	>=dev-python/pathspec-0.11.1[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.1[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-env-tag-0.1[${PYTHON_USEDEP}]
	>=dev-python/watchdog-2.0[${PYTHON_USEDEP}]
	i18n? ( >=dev-python/babel-2.9.0[${PYTHON_USEDEP}] )
"

# The custom hatch build hook compiles the bundled gettext catalogs (.mo)
# at build time; that needs babel, plus setuptools on py3.12+ (no distutils).
BDEPEND="
	dev-python/babel[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
"
