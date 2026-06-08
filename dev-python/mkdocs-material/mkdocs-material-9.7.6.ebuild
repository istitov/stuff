# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="A Material Design theme for MkDocs"
HOMEPAGE="
	https://squidfunk.github.io/mkdocs-material/
	https://github.com/squidfunk/mkdocs-material
	https://pypi.org/project/mkdocs-material/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/babel-2.10[${PYTHON_USEDEP}]
	>=dev-python/backrefs-5.7_p1[${PYTHON_USEDEP}]
	>=dev-python/colorama-0.4[${PYTHON_USEDEP}]
	>=dev-python/jinja2-3.1[${PYTHON_USEDEP}]
	>=dev-python/markdown-3.2[${PYTHON_USEDEP}]
	>=dev-python/mkdocs-material-extensions-1.3[${PYTHON_USEDEP}]
	>=dev-python/mkdocs-1.6[${PYTHON_USEDEP}]
	<dev-python/mkdocs-2[${PYTHON_USEDEP}]
	>=dev-python/paginate-0.5[${PYTHON_USEDEP}]
	>=dev-python/pygments-2.16[${PYTHON_USEDEP}]
	>=dev-python/pymdown-extensions-10.2[${PYTHON_USEDEP}]
	>=dev-python/requests-2.30[${PYTHON_USEDEP}]
"

# Extra build-backend plugins from [build-system].requires: version comes
# from package.json (hatch-nodejs-version), runtime deps from requirements.txt
# (hatch-requirements-txt), and the "Framework :: MkDocs" trove classifier.
BDEPEND="
	dev-python/hatch-nodejs-version[${PYTHON_USEDEP}]
	dev-python/hatch-requirements-txt[${PYTHON_USEDEP}]
	>=dev-python/trove-classifiers-2023.10.18[${PYTHON_USEDEP}]
"
