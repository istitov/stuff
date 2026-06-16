# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="An extra command for MkDocs that infers required PyPI packages"
HOMEPAGE="
	https://github.com/mkdocs/get-deps
	https://pypi.org/project/mkdocs-get-deps/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/mergedeep-1.3.4[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-2.2.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.1[${PYTHON_USEDEP}]
"
